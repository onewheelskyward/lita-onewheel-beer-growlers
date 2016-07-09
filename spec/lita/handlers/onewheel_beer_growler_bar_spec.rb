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
    expect(replies.last).to eq("taps: 1) Bayreuther Aktien Helles Lager  2) Boneyard Armored Fist - Big,Black&Hoppy  3) Magnolia Barrel Aged Old Thunderpussy  4) Russian River Blind Pig - IPA  5) Magnolia Blue Bell Bitter   6) Boneyard Bone-A-Fide - Pale  7) Knee Deep Breaking Bud - IPA  8) Hamm's Cheap, cold  9) Two Rivers Cider- Huckleberry  10) Cider Riot! Cider- NeverGiveAnInch -Rosé   11) Bockor Cuvée des Jacobins Rouge*  12) Magnolia Delilah Jones '15 - StrongRye  13) Alpine Duet - IPA  14) NewBelg&amp;HofTenDormaal Golden - Herbs,Seeds,Spelt  15) Stiegl Grapefruit Radler  16) Barley Brown's Handtruck - Pale  17) Barley Brown's Head Shake - IIPA  18) Boneyard Hop Venom - IIPA  19) Ayinger Jahrhundert - Export Lager  20) Magnolia Kalifornia Kolsch  21) Weihenstephan Kristallweissbier  22) New Belgium Le Terroir*  23) Knee Deep Lupulin River - IPA  24) Gebruder Maisel Maisel's Weisse - Hefeweizen   25) Hair of the Dog Nitro- Adam -Drinking Tobacco  26) Dieu du Ciel! Nitro- Aphrodisiaque - Stout   27) North Coast Nitro- Old Rasputin - RIS  28) North Coast Nitro- Red Seal - Red  29) Boulder Nitro- Shake - Choco Porter  30) Guinness Nitro- Stout  31) Boneyard Notorious - IIIPA  32) Crux Off Leash - NW Session Ale  33) Rogue Old Crustacean '12-Barleywine  34) Barley Brown's Pallet Jack - IPA  35) Prairie Phantasmagoria - IPA  36) Radeberger Pilsner  37) Russian River Pliny The Elder  38) Prairie Prairie-Vous Francais - Saison   Just Tapped  39) Magnolia Proving Ground - IPA  40) Crux Prowell Springs - Pilsner  41) Dupont Saison  42) Magnolia Saison de Lily  43) Against the Grain Sho' Nuff - Belgian Pale  44) To Øl Simple Life - Lacto Saison*  45) Magnolia Stout of Circumstance  46) Perennial  Sump - Imp Coffee Stout  47) Against the Grain Tex Arcana - Stout  48) Bosteels Tripel Karmeliet  49) Gigantic Vivid - IIPA  50) Barley Brown's WFO - IPA")
  end

  it 'displays details for tap 4' do
    send_command 'growlers 4'
    expect(replies.last).to eq('Apex tap 4) Blind Pig - IPA 6.1%, $6')
  end

  it 'doesn\'t explode on 1' do
    send_command 'growlers 1'
    expect(replies.count).to eq(1)
    expect(replies.last).to eq('Apex tap 1) Aktien Helles Lager 5.3%, $5')
  end

  it 'gets nitro' do
    send_command 'growlers nitro'
    expect(replies.last).to eq('Apex tap 30) Nitro- Stout 4.1%, $4')
  end

  it 'searches for ipa' do
    send_command 'growlers ipa'
    expect(replies.last).to eq('Apex tap 50) WFO - IPA 7.5%, $5')
  end

  # it 'searches for brown' do
  #   send_command 'growlers brown'
  #   expect(replies.last).to eq("Bailey's tap 22) GoodLife 29er - India Brown Ale 6.0%, 10oz - $3 | 20oz - $5 | 32oz Crowler - $8, 37% remaining")
  # end

  it 'searches for abv >9%' do
    send_command 'growlers >9%'
    expect(replies.count).to eq(8)
    expect(replies[0]).to eq('Apex tap 2) Armored Fist - Big,Black&Hoppy 10.0%, $5')
    expect(replies[1]).to eq('Apex tap 3) Barrel Aged Old Thunderpussy 10.8%, $5')
    expect(replies.last).to eq('Apex tap 46) Sump - Imp Coffee Stout 10.5%, $5')
  end

  it 'searches for abv > 9%' do
    send_command 'growlers > 9%'
    expect(replies.count).to eq(8)
    expect(replies[0]).to eq('Apex tap 2) Armored Fist - Big,Black&Hoppy 10.0%, $5')
    expect(replies[1]).to eq('Apex tap 3) Barrel Aged Old Thunderpussy 10.8%, $5')
    expect(replies.last).to eq('Apex tap 46) Sump - Imp Coffee Stout 10.5%, $5')
  end

  it 'searches for abv >= 9%' do
    send_command 'growlers >= 9%'
    expect(replies.count).to eq(10)
    expect(replies[0]).to eq('Apex tap 2) Armored Fist - Big,Black&Hoppy 10.0%, $5')
    expect(replies.last).to eq('Apex tap 46) Sump - Imp Coffee Stout 10.5%, $5')
  end

  it 'searches for abv <4.1%' do
    send_command 'growlers <4.1%'
    expect(replies.count).to eq(2)
    expect(replies[0]).to eq('Apex tap 15) Grapefruit Radler 2.5%, $5')
    expect(replies.last).to eq('Apex tap 38) Prairie-Vous Francais - Saison   Just Tapped 3.9%, $5')
  end

  it 'searches for abv <= 4%' do
    send_command 'growlers <= 4%'
    expect(replies.count).to eq(2)
    expect(replies[0]).to eq('Apex tap 15) Grapefruit Radler 2.5%, $5')
    expect(replies.last).to eq('Apex tap 38) Prairie-Vous Francais - Saison   Just Tapped 3.9%, $5')
  end

  it 'searches for prices >$5' do
    send_command 'growlers >$5'
    expect(replies.count).to eq(11)
    expect(replies[0]).to eq('Apex tap 4) Blind Pig - IPA 6.1%, $6')
    expect(replies[1]).to eq('Apex tap 21) Kristallweissbier 5.4%, $6')
  end

  it 'searches for prices >=$6' do
    send_command 'growlers >=$6'
    expect(replies.count).to eq(11)
    expect(replies[0]).to eq('Apex tap 4) Blind Pig - IPA 6.1%, $6')
  end

  it 'searches for prices > $6' do
    send_command 'growlers > $6'
    expect(replies.count).to eq(3)
    expect(replies[0]).to eq('Apex tap 29) Nitro- Shake - Choco Porter 5.9%, $8')
  end

  it 'searches for prices <$4.1' do
    send_command 'growlers <$4.1'
    expect(replies.count).to eq(4)
    expect(replies[0]).to eq('Apex tap 8) Cheap, cold 4.7%, $3')
  end

  it 'searches for prices < $4.01' do
    send_command 'growlers < $4.01'
    expect(replies.count).to eq(4)
    expect(replies[0]).to eq('Apex tap 8) Cheap, cold 4.7%, $3')
  end

  it 'searches for prices <= $4.00' do
    send_command 'growlers <= $4.00'
    expect(replies.count).to eq(4)
    expect(replies[0]).to eq('Apex tap 8) Cheap, cold 4.7%, $3')
  end

  it 'runs a random beer through' do
    send_command 'growlers roulette'
    expect(replies.count).to eq(1)
    expect(replies.last).to include('Apex tap')
  end

  it 'runs a random beer through' do
    send_command 'growlers random'
    expect(replies.count).to eq(1)
    expect(replies.last).to include('Apex tap')
  end

  it 'searches with a space' do
    send_command 'growlers cider riot'
    expect(replies.last).to eq('Apex tap 10) Cider- NeverGiveAnInch -Rosé  6.9%, $5')
  end

  it 'displays low abv' do
    send_command 'growlersabvhigh'
    expect(replies.last).to eq('Apex tap 31) Notorious - IIIPA 11.5%, $5')
  end

  it 'displays high abv' do
    send_command 'growlersabvlow'
    expect(replies.last).to eq('Apex tap 15) Grapefruit Radler 2.5%, $5')
  end
end
