require 'spec_helper'

describe Paperclip::ContentTypeDetector do
  it 'gives a sensible default when the name is empty' do
    assert_equal "application/octet-stream", Paperclip::ContentTypeDetector.new("").detect
  end

  it 'returns the empty content type when the file is empty' do
    tempfile = Tempfile.new("empty")
    assert_equal "inode/x-empty", Paperclip::ContentTypeDetector.new(tempfile.path).detect
    tempfile.close
  end

  it 'returns content type of file if it is an acceptable type' do
    MIME::Types.stubs(:type_for).returns([MIME::Type.new('application/mp4'), MIME::Type.new('video/mp4'), MIME::Type.new('audio/mp4')])
    Paperclip.stubs(:run).returns("video/mp4")
    @filename = "my_file.mp4"
    assert_equal "video/mp4", Paperclip::ContentTypeDetector.new(@filename).detect
  end

  it 'returns content type of file if it is an acceptable type' do
    MIME::Types.stubs(:type_for).returns([MIME::Type.new('text/csv')])
    Paperclip.stubs(:run).returns("text/plain")
    @filename = "my_file.csv"
    assert_equal "text/csv", Paperclip::ContentTypeDetector.new(@filename).detect
  end

  it 'finds the right type in the list via the file command' do
    @filename = "#{Dir.tmpdir}/something.hahalolnotreal"
    File.open(@filename, "w+") do |file|
      file.puts "This is a text file."
      file.rewind
      assert_equal "text/plain", Paperclip::ContentTypeDetector.new(file.path).detect
    end
    FileUtils.rm @filename
  end

  it 'returns a sensible default if something is wrong, like the file is gone' do
    @filename = "/path/to/nothing"
    assert_equal "application/octet-stream", Paperclip::ContentTypeDetector.new(@filename).detect
  end

  it 'returns a sensible default when the file command is missing' do
    Paperclip.stubs(:run).raises(Cocaine::CommandLineError.new)
    @filename = "/path/to/something"
    assert_equal "application/octet-stream", Paperclip::ContentTypeDetector.new(@filename).detect
  end
end
