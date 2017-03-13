describe Gmail::Filters::Xml::Doc do
  let :filter do
    Gmail::Filters::Model::Filter.new(
      only: ['to:foo'],
      except: ['from:bar'],
      label: 'label',
      mark_read: true,
      archive: true,
      delete: true
    )
  end

  let :set     { Gmail::Filters::Model::Set.new }
  let :filters { Gmail::Filters::Model::Filters.new(author: 'author', email: 'email') }

  before  { set.filters << filter }
  before  { filters.sets << set }

  subject { described_class.new(filters).render }

  it do
    should eq <<~xml
      <?xml version='1.0' encoding='utf-8' ?>
      <feed xmlns:apps='http://schemas.google.com/apps/2006' xmlns='http://www.w3.org/2005/Atom'>
        <title>Mail Filters</title>
        <id>tag:mail.google.com,2008:filters:</id>
        <updated>2017-03-12T18:29:46Z</updated>
        <author>
          <name>author</name>
          <email>email</email>
        </author>
        <entry>
          <category term="filter"></category>
          <title>Mail Filter</title>
          <content></content>
          <apps:property name="hasTheWord" value="to:foo AND -from:bar"></apps:property>
          <apps:property name="label" value="label"></apps:property>
          <apps:property name="shouldMarkAsRead" value="true"></apps:property>
          <apps:property name="shouldArchive" value="true"></apps:property>
          <apps:property name="shouldTrash" value="true"></apps:property>
        </entry>
      </feed>
    xml
  end
end
