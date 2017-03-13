describe Gmail::Filters::Dsl::Set do
  let  :set   { Gmail::Filters::Model::Set.new }
  let! :dsl   { described_class.new(set, &block) }

  subject { set.filters.last.to_h }

  describe 'filter' do
    context do
      let :block { ->(f) { filter { from 'foo' } } }
      it { should eq has: 'from:foo' }
    end

    context do
      let :block { ->(f) { filter { to 'foo' } } }
      it { should eq has: 'to:foo' }
    end

    context do
      let :block { ->(f) { filter { list 'foo' } } }
      it { should eq has: 'list:foo' }
    end

    context do
      let :block { ->(f) { filter { has 'from:foo' } } }
      it { should eq has: 'from:foo' }
    end

    context do
      let :block { ->(f) { filter { label 'label' } } }
      it { should eq label: 'label' }
    end

    context do
      let :block { ->(f) { filter { mark_read } } }
      it { should eq mark_read: true }
    end

    context do
      let :block { ->(f) { filter { archive } } }
      it { should eq archive: true }
    end

    context do
      let :block { ->(f) { filter { delete } } }
      it { should eq delete: true }
    end
  end

  describe 'otherwise' do
    let :block do
      ->(f) do
        filter    { from 'foo'; list 'bar' }
        filter    { from 'foo'; list 'baz' }
        otherwise { from 'foo'; list 'bum' }
        otherwise { from 'foo'; list 'bam' }
      end
    end

    it { should eq has: 'from:foo AND list:bam AND -(from:foo AND (list:bar OR list:baz OR list:bum))' }
  end
end
