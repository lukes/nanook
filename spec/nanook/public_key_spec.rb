# frozen_string_literal: true

RSpec.describe Nanook::PublicKey do
  let(:uri) { Nanook::Rpc::DEFAULT_URI }
  let(:key) { '781186FB9EF17DB6E3D1056550D9FAE5D5BBADA6A6BC370E4CBB938B1DC71DA3' }

  it 'can compare equality' do
    key_1 = Nanook.new.public_key("foo")
    key_2 = Nanook.new.public_key("foo")
    key_3 = Nanook.new.public_key("bar")

    expect(key_1).to eq(key_2)
    expect(key_1).not_to eq(key_3)
  end

  it 'can be used as a hash key lookup' do
    hash = {
      Nanook.new.public_key("foo") => "found"
    }

    expect(hash[Nanook.new.public_key("foo")]).to eq("found")
  end

  it 'should request account correctly' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"account_get\",\"key\":\"#{key}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"account\":\"nano_1e5aqegc1jb7qe964u4adzmcezyo6o146zb8hm6dft8tkp79za3sxwjym5rx\"}",
      headers: {}
    )

    account = Nanook.new.public_key(key).account

    expect(account).to be_kind_of(Nanook::Account)
    expect(account.id).to eq("nano_1e5aqegc1jb7qe964u4adzmcezyo6o146zb8hm6dft8tkp79za3sxwjym5rx")
  end
end
