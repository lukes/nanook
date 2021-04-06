# frozen_string_literal: true

RSpec.describe Nanook::Key do
  let(:uri) { Nanook::Rpc::DEFAULT_URI }
  let(:key) { '781186FB9EF17DB6E3D1056550D9FAE5D5BBADA6A6BC370E4CBB938B1DC71DA3' }

  it 'can compare equality' do
    key_1 = Nanook.new.key("foo")
    key_2 = Nanook.new.key("foo")
    key_3 = Nanook.new.key("bar")

    expect(key_1).to eq(key_2)
    expect(key_1).not_to eq(key_3)
  end

  it 'can be used as a hash key lookup' do
    hash = {
      Nanook.new.key("foo") => "found"
    }

    expect(hash[Nanook.new.key("foo")]).to eq("found")
  end


  it 'should request info correctly' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"key_expand\",\"key\":\"#{key}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"private\":\"781186FB9EF17DB6E3D1056550D9FAE5D5BBADA6A6BC370E4CBB938B1DC71DA3\",
      \"public\":\"3068BB1CA04525BB0E416C485FE6A67FD52540227D267CC8B6E8DA958A7FA039\",
      \"account\":\"nano_1e5aqegc1jb7qe964u4adzmcezyo6o146zb8hm6dft8tkp79za3sxwjym5rx\"}",
      headers: {}
    )

    expect(Nanook.new.key(key).info).to have_key(:private)
  end

  it 'should create a key correctly' do
    stub_request(:post, uri).with(
      body: '{"action":"key_create"}',
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"private\":\"781186FB9EF17DB6E3D1056550D9FAE5D5BBADA6A6BC370E4CBB938B1DC71DA3\",
      \"public\":\"3068BB1CA04525BB0E416C485FE6A67FD52540227D267CC8B6E8DA958A7FA039\",
      \"account\":\"nano_1e5aqegc1jb7qe964u4adzmcezyo6o146zb8hm6dft8tkp79za3sxwjym5rx\"}",
      headers: {}
    )

    expect(Nanook.new.key.generate).to have_key(:private)
  end

  it 'should create a key with seed and index correctly' do
    seed = '0000000000000000000000000000000000000000000000000000000000000000'

    stub_request(:post, uri).with(
      body: "{\"action\":\"deterministic_key\",\"seed\":\"#{seed}\",\"index\":\"0\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"private\":\"781186FB9EF17DB6E3D1056550D9FAE5D5BBADA6A6BC370E4CBB938B1DC71DA3\",
      \"public\":\"3068BB1CA04525BB0E416C485FE6A67FD52540227D267CC8B6E8DA958A7FA039\",
      \"account\":\"nano_1e5aqegc1jb7qe964u4adzmcezyo6o146zb8hm6dft8tkp79za3sxwjym5rx\"}",
      headers: {}
    )

    expect(Nanook.new.key.generate(seed: seed, index: 0)).to have_key(:private)
  end

  it 'should raise an exception if seed or index is provided but not both' do
    expect { Nanook.new.key.generate(seed: 'seed') }.to raise_error(ArgumentError)
    expect { Nanook.new.key.generate(index: 1) }.to raise_error(ArgumentError)
  end
end
