require 'zip'

class FileController < ApplicationController
  def index
    @password = ENV['PASSWORD'].present? ? Date.today.strftime(ENV['PASSWORD']) : ""
    @zip_id = SecureRandom.hex(16)
    gon.zip_id = @zip_id
  end

  def create
    tmp_path = File.join("/tmp/", params[:zip_id])
    FileUtils.mkdir_p(tmp_path)
    file_path = File.join(tmp_path, params[:file].original_filename)
    File.open(file_path, 'wb') do |f|
      f.write(params[:file].read)
    end
    render json: {status: "success"}
  end

  def download
    zip_id = params[:id]
    unless File.exist?(File.join("/tmp/", zip_id))
      redirect_to :file_index
      return
    end
    encrypter = params[:password].present? ? Zip::TraditionalEncrypter.new(params[:password]) : nil
    io = StringIO.new('')
    io.set_encoding(Encoding::CP932)
    buffer = Zip::OutputStream.write_buffer(io, encrypter) do |zos|
      Dir.glob(File.join("/tmp/", zip_id, "*")).each do |file_path|
        zos.put_next_entry File.basename(file_path).encode("Shift_JIS")
        open(file_path, "rb") do |f|
          zos.write f.read
        end
      end
    end
    send_data buffer.string, filename: "#{zip_id}.zip", type: 'application/zip', disposition: 'attachment'
  end
end
