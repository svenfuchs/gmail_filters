require 'fileutils'

describe Gmail::Filters::Cli::Export do
  let :path { 'tmp/filter.rb' }

  let :source do
    <<~str
      filter do
        from 'notify@twitter.com'
        label 'notifications/twitter'
        archive
      end

      filter do
        from '*@facebookmail.com'
        delete
      end
    str
  end

  let :cmd { described_class.new(source: path, author: 'author', email: 'email') }

  before   { FileUtils.mkdir('tmp') }
  before   { File.write(path, source) }
  after    { FileUtils.rm_rf('tmp') }

  subject  { cmd.run }

  it { expect(subject).to start_with %(<?xml version='1.0' encoding='utf-8' ?>) }
  it { expect(subject).to include '<name>author</name>' }
  it { expect(subject).to include '<email>email</email>' }
  it { expect(subject).to include '<apps:property name="hasTheWord" value="from:notify@twitter.com">' }
  it { expect(subject).to include '<apps:property name="label" value="notifications/twitter">' }
  it { expect(subject).to include '<apps:property name="shouldArchive" value="true"></apps:property>' }
  it { expect(subject).to include '<apps:property name="hasTheWord" value="from:*@facebookmail.com">' }
  it { expect(subject).to include '<apps:property name="shouldTrash" value="true">' }
end
