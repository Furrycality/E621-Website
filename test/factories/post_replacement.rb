FactoryBot.define do
  factory(:post_replacement) do
    creator_ip_addr { "127.0.0.1" }
    replacement_url { FFaker::Internet.http_url }
    reason { FFaker::Lorem.words.join(" ") }

    factory(:webm_replacement) do
      replacement_file do
        f = Tempfile.new
        IO.copy_stream("#{Rails.root}/test/files/test-512x512.webm", f.path)
        ActionDispatch::Http::UploadedFile.new(tempfile: f, filename: "video.webm")
      end
    end

    factory(:jpg_replacement) do
      replacement_file do
        f = Tempfile.new
        IO.copy_stream("#{Rails.root}/test/files/test.jpg", f.path)
        ActionDispatch::Http::UploadedFile.new(tempfile: f, filename: "test.jpg")
      end
    end

    factory(:jpg_invalid_replacement) do
      replacement_file do
        f = Tempfile.new
        IO.copy_stream("#{Rails.root}/test/files/test-corrupt.jpg", f.path)
        ActionDispatch::Http::UploadedFile.new(tempfile: f, filename: "test.jpg")
      end
    end

    factory(:gif_replacement) do
      replacement_file do
        f = Tempfile.new
        IO.copy_stream("#{Rails.root}/test/files/test.gif", f.path)
        ActionDispatch::Http::UploadedFile.new(tempfile: f, filename: "test.gif")
      end
    end

    factory(:empty_replacement) do
      replacement_file do
        f = Tempfile.new
        IO.copy_stream("#{Rails.root}/test/files/empty.jpg", f.path)
        ActionDispatch::Http::UploadedFile.new(tempfile: f, filename: "test.jpg")
      end
    end

    factory(:png_replacement) do
      replacement_file do
        f = Tempfile.new
        IO.copy_stream("#{Rails.root}/test/files/test.png", f.path)
        ActionDispatch::Http::UploadedFile.new(tempfile: f, filename: "test.png")
      end
    end
  end
end
