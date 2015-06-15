describe 'Engine_kifuread' do
  require_relative '../app/lib/engine_kifu'
  require_relative '../app/lib/engine'

  it 'Engineクラスの継承であること' do
    expect(Engine_kifuread.superclass.class).to eq Engine.class
  end

  it 'インスタンス生成時に棋譜データをインスタンス変数配列に格納する' do
    expect(Engine_kifuread.new()).to eq Engine.class
  end
  describe '#get_sasite' do
    let(:e_kifuread) {Engine_kifuread.new()}
  end
end
