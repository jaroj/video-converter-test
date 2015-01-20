class ConverterJob < ActiveJob::Base
  queue_as :default

  def perform(tmpfile, encoded_file, model, opts = {})
    file = ::FFMPEG::Movie.new(tmpfile)
    if file.valid? # true (would be false if ffmpeg fails to read the movie)
      file.screenshot("screenshot.png", { seek_time: 10, resolution: '400x300' })
      file.transcode(encoded_file, opts) { |progress| puts "#{(progress*100).round(2)} %" }
      model.model.finished! # change status and save
    else
      model.model.error!
    end
    File.delete(tmpfile)
  end
end
