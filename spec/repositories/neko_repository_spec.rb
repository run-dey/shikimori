describe NekoRepository do
  let(:service) { NekoRepository.instance }

  describe 'enumerable' do
    it do
      expect(service.first).to be_kind_of Neko::Rule
      expect(service).to have_at_least(10).items
    end
  end

  describe '#find' do
    it do
      expect(service.find [:animelist, 'animelist'].sample, ['1', 1].sample)
        .to be_kind_of Neko::Rule
      expect(service.find %i[test zxc].sample, 1).to eq Neko::Rule::NO_RULE
    end
  end
end
