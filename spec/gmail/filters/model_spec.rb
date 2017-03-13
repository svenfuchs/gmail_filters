describe Gmail::Filters::Model::Filter do
  let :attrs do
    {
      only: ['to:foo'],
      except: ['from:bar'],
      label: 'label',
      mark_read: true,
      archive: true,
      delete: true
    }
  end

  subject { described_class.new(attrs).to_h }

  it do
    should eq(
      has: 'to:foo AND -from:bar',
      label: 'label',
      mark_read: true,
      archive: true,
      delete: true
    )
  end
end
