require 'test_helper'

class ArtistUrlTest < ActiveSupport::TestCase
  def assert_search_equals(results, conditions)
    assert_equal(results.map(&:id), subject.search(conditions).map(&:id))
  end

  context "An artist url" do
    setup do
      CurrentUser.user = FactoryBot.create(:user)
      CurrentUser.ip_addr = "127.0.0.1"
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    should "allow urls to be marked as inactive" do
      url = FactoryBot.create(:artist_url, url: "http://monet.com", is_active: false)
      assert_equal("http://monet.com", url.url)
      assert_equal("http://monet.com/", url.normalized_url)
      assert_equal("-http://monet.com", url.to_s)
    end

    should "disallow invalid urls" do
      url = FactoryBot.build(:artist_url, url: "www.example.com")

      assert_equal(false, url.valid?)
      assert_match(/must begin with http/, url.errors.full_messages.join)
    end

    should "always add a trailing slash when normalized" do
      url = FactoryBot.create(:artist_url, :url => "http://monet.com")
      assert_equal("http://monet.com", url.url)
      assert_equal("http://monet.com/", url.normalized_url)

      url = FactoryBot.create(:artist_url, :url => "http://monet.com/")
      assert_equal("http://monet.com/", url.url)
      assert_equal("http://monet.com/", url.normalized_url)
    end

    should "normalise https" do
      url = FactoryBot.create(:artist_url, :url => "https://google.com")
      assert_equal("https://google.com", url.url)
      assert_equal("http://google.com/", url.normalized_url)
    end

    should "normalise domains to lowercase" do
      url = FactoryBot.create(:artist_url, url: "https://ArtistName.example.com")
      assert_equal("http://artistname.example.com/", url.normalized_url)
    end

    context "#search method" do
      subject { ArtistUrl }

      should "work" do
        @bkub = FactoryBot.create(:artist, name: "bkub", is_active: true, url_string: "https://bkub.com")
        as_admin do
          @masao = FactoryBot.create(:artist, name: "masao", is_active: false, url_string: "-https://masao.com")
        end
        @bkub_url = @bkub.urls.first
        @masao_url = @masao.urls.first

        assert_search_equals([@bkub_url], is_active: true)
        assert_search_equals([@bkub_url], artist: { name: "bkub" })

        assert_search_equals([@bkub_url], url_matches: "*bkub*")
        assert_search_equals([@bkub_url], url_matches: "/^https?://bkub\.com$/")

        assert_search_equals([@bkub_url], normalized_url_matches: "*bkub*")
        assert_search_equals([@bkub_url], normalized_url_matches: "/^https?://bkub\.com/$/")
        assert_search_equals([@bkub_url], normalized_url_matches: "https://bkub.com")

        assert_search_equals([@bkub_url], url: "https://bkub.com")
        assert_search_equals([@bkub_url], url_eq: "https://bkub.com")
        assert_search_equals([@bkub_url], url_not_eq: "https://masao.com")
        assert_search_equals([@bkub_url], url_like: "*bkub*")
        assert_search_equals([@bkub_url], url_ilike: "*BKUB*")
        assert_search_equals([@bkub_url], url_not_like: "*masao*")
        assert_search_equals([@bkub_url], url_not_ilike: "*MASAO*")
      end
    end
  end
end
