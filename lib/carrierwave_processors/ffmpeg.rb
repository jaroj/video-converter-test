module CarrierWave
  module FFMPEG
    module ClassMethods
      def encode_video(target_format)
        process encode_video: [target_format]
      end
    end

    def encode_video(format)
      directory = File.dirname(current_path)
      tmpfile = File.join(directory, 'tmpfile')
      File.rename(current_path, tmpfile)

      new_name = File.basename(current_path, '.*') + '.' + format.to_s
      current_extenstion = File.extname(current_path).gsub('.', '')
      encoded_file = File.join(directory, new_name)
      # adding some options
      options = { video_min_bitrate: 600, resolution: '320x240' }

      self.model.status = 1 # set status as started but not save yet
      # add ActiveJob job
      ConverterJob.perform_later(tmpfile, encoded_file, self.model, options)

      # warning: magic!
      # change format for uploaded file name and store file format
      # without this lines processed video files will remain in cache folder
      self.filename[-current_extenstion.size..-1] = format.to_s
      self.file.file[-current_extenstion.size..-1] = format.to_s
    end
  end
end
