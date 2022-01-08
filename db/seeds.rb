# frozen_string_literal: true

require "digest/md5"
require "net/http"
require "tempfile"

unless Rails.env.test?
  puts "== Creating elasticsearch indices ==\n"

  Post.__elasticsearch__.create_index!
end

puts "== Seeding database with sample content ==\n"

# Uncomment to see detailed logs
#ActiveRecord::Base.logger = ActiveSupport::Logger.new($stdout)

admin = User.find_or_create_by!(name: "admin") do |user|
  user.created_at = 2.weeks.ago
  user.password = "e621test"
  user.password_confirmation = "e621test"
  user.password_hash = ""
  user.email = "admin@e621.net"
  user.can_upload_free = true
  user.can_approve_posts = true
  user.level = User::Levels::ADMIN
end

User.find_or_create_by!(name: Danbooru.config.system_user) do |user|
  user.password = "ae3n4oie2n3oi4en23oie4noienaorshtaioresnt"
  user.password_confirmation = "ae3n4oie2n3oi4en23oie4noienaorshtaioresnt"
  user.password_hash = ""
  user.email = "system@e621.net"
  user.can_upload_free = true
  user.can_approve_posts = true
  user.level = User::Levels::JANITOR
end

ForumCategory.find_or_create_by!(id: Danbooru.config.alias_implication_forum_category) do |category|
  category.name = "Tag Alias and Implication Suggestions"
  category.can_view = 0
end

unless Rails.env.test?
  CurrentUser.user = admin
  CurrentUser.ip_addr = "127.0.0.1"

  resources = YAML.load_file Rails.root.join("db", "seeds.yml")
  url = "https://e621.net/posts.json?limit=#{ENV.fetch("SEED_POST_COUNT", 100)}&tags=id:#{resources["post_ids"].join(",")}"
  response = HTTParty.get(url, {
    headers: {"User-Agent" => "e621ng/seeding"}
  })
  json = JSON.parse(response.body)

  json["posts"].each do |post|
    puts post["file"]["url"]

    data = Net::HTTP.get(URI(post["file"]["url"]))
    file = Tempfile.new.binmode
    file.write data

    post["tags"].each do |category, tags|
      Tag.find_or_create_by_name_list(tags.map {|tag| category + ":" + tag})
    end

    md5 = Digest::MD5.hexdigest(data)
    service = UploadService.new({
                                    uploader_id: CurrentUser.id,
                                    uploader_ip_addr: CurrentUser.ip_addr,
                                    file: file,
                                    tag_string: post["tags"].values.flatten.join(" "),
                                    source: post["sources"].join("\n"),
                                    description: post["description"],
                                    rating: post["rating"],
                                    md5: md5,
                                    md5_confirmation: md5
                                })

    service.start!
  end
end
