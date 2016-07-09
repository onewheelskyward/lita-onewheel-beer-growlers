require 'spec_helper'

describe Lita::Handlers::OnewheelBeerGrowlers, lita_handler: true do
  it { is_expected.to route_command('growlers') }
  it { is_expected.to route_command('growlers 4') }
  it { is_expected.to route_command('growlers nitro') }
  it { is_expected.to route_command('growlers CASK') }
  it { is_expected.to route_command('growlers <$4') }
  it { is_expected.to route_command('growlers < $4') }
  it { is_expected.to route_command('growlers <=$4') }
  it { is_expected.to route_command('growlers <= $4') }
  it { is_expected.to route_command('growlers >4%') }
  it { is_expected.to route_command('growlers > 4%') }
  it { is_expected.to route_command('growlers >=4%') }
  it { is_expected.to route_command('growlers >= 4%') }
  it { is_expected.to route_command('growlersabvhigh') }
  it { is_expected.to route_command('growlersabvlow') }

  before do
    mock = File.open('spec/fixtures/growlers.json').read
    allow(RestClient).to receive(:get) { mock }
  end

  it 'shows the taps' do
    send_command 'growlers'
    expect(replies.last).to eq("taps: 1) Ex Novo Star Spangled Lager  2) pFriem Helles  3) ColdFire German Pilsner  4) Drinking Horse Spring Wit  5) Upright Side Line  6) Flat Tail El Guapo  7) Flat Tail Dam Wild: Hops & Lemon Verbena  8) Sunriver Fuzztail  9) Victory Kirsch Gose  10) Double Mountain Little Red Pils  11) Fort George Spruce Budd Ale  12) Stickmen Kissed by Melons  13) Golden Valley Red Thistle Ale  14) Viking Braggot Co. Pathfinder  16) Deschutes Hop Slice  17) Ancestry Best Coast IPA  18) Belching Beaver Here Comes Mango!  19) Ex Novo German IPA  20) Mazama Mosaic Eruption  21) Buoy IPA  23) Boneyard Hop Venom  24) Ex Novo Dynamic Duo  26) Bear Republic Mach 10 Imperial IPA  27) Uptown Market Oatis Reddin'  28) Double Mountain Pale Death  29) Mazama El Duque do Porto  30) Sound Brewery Dubbel Entendre  31) Magnolia Cole Porter  32) Barley Brown's Breakfast Stout  33) Ex Novo Coconut Vanilla Porter  34) Gingerade  35) Hibiscus No. 7  36) Bad Apple  38) Sunny Cider  39) Wholesome Apple")
  end

  it 'displays details for tap 4' do
    send_command 'growlers 4'
    expect(replies.last).to eq('Growlers tap 4) Spring Wit $12.99')
  end

  it 'doesn\'t explode on 1' do
    send_command 'growlers 1'
    expect(replies.count).to eq(2)
    expect(replies.last).to eq('Growlers tap 1) Star Spangled Lager $9.99')
  end

  it 'searches for ipa' do
    send_command 'growlers ipa'
    expect(replies.last).to eq('Growlers tap 26) Mach 10 Imperial IPA $17.99')
  end

  # it 'searches for brown' do
  #   send_command 'growlers brown'
  #   expect(replies.last).to eq("Bailey's tap 22) GoodLife 29er - India Brown Ale 6.0%, 10oz - $3 | 20oz - $5 | 32oz Crowler - $8, 37% remaining")
  # end

  it 'searches for prices >$11' do
    send_command 'growlers >$11'
    expect(replies.count).to eq(29)
    expect(replies[1]).to eq('Growlers tap 2) Helles $11.99')
  end

  it 'runs a random beer through' do
    send_command 'growlers roulette'
    expect(replies.count).to eq(2)
    expect(replies.last).to include('Growlers tap')
  end

  it 'runs a random beer through' do
    send_command 'growlers random'
    expect(replies.count).to eq(2)
    expect(replies.last).to include('Growlers tap')
  end

  # it 'searches with a space' do
  #   send_command 'growlers cider riot'
  #   expect(replies.last).to eq('Apex tap 10) Cider- NeverGiveAnInch -Rosé  6.9%, $5')
  # end
end
