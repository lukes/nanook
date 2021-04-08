# frozen_string_literal: true

RSpec.describe Nanook::Wallet do
  let(:uri) { Nanook::Rpc::DEFAULT_URI }
  let(:account_id) { 'nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000' }
  let(:wallet_id) { '000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F' }
  let(:block_id) { '000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F' }

  def stub_valid_account_check
    stub_request(:post, 'http://localhost:7076/')
      .with(
        body: '{"action":"wallet_contains","wallet":"000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F","account":"nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000"}',
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Content-Type' => 'application/json',
          'User-Agent' => 'Ruby nanook gem'
        }
      )
      .to_return(status: 200, body: '{"exists":"1"}', headers: {})
  end

  it 'can compare equality' do
    wallet_1 = Nanook.new.wallet("foo")
    wallet_2 = Nanook.new.wallet("foo")
    wallet_3 = Nanook.new.wallet("bar")

    expect(wallet_1).to eq(wallet_2)
    expect(wallet_1).not_to eq(wallet_3)
  end

  it 'can be used as a hash key lookup' do
    hash = {
      Nanook.new.wallet("foo") => "found"
    }

    expect(hash[Nanook.new.wallet("foo")]).to eq("found")
  end


  it 'should have an account method' do
    expect(Nanook.new.wallet(wallet_id).account).to be_kind_of(Nanook::WalletAccount)
  end

  it 'wallet accounts' do
    stub_valid_account_check

    stub_request(:post, uri).with(
      body: "{\"action\":\"account_list\",\"wallet\":\"#{wallet_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"accounts":["nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000"]}',
      headers: {}
    )

    response = Nanook.new.wallet(wallet_id).accounts
    expect(response).to have(1).item
    expect(response.first).to be_kind_of Nanook::WalletAccount
    expect(response.first.id).to eq 'nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000'
  end

  it 'wallet accounts when blank' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"account_list\",\"wallet\":\"#{wallet_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"accounts":""}',
      headers: {}
    )

    expect(Nanook.new.wallet(wallet_id).accounts).to eq []
  end

  it 'wallet create' do
    stub_request(:post, uri).with(
      body: '{"action":"wallet_create"}',
      headers: headers
    ).to_return(
      status: 200,
      body: '{"wallet":"000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F"}',
      headers: {}
    )

    response = Nanook.new.wallet.create
    expect(response).to be_kind_of Nanook::Wallet
    expect(response.id).to eq '000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F'
  end

  it 'wallet destroy' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_destroy\",\"wallet\":\"#{wallet_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"destroyed": "1"}',
      headers: {}
    )

    expect(Nanook.new.wallet(wallet_id).destroy).to be true
  end

  it 'account move' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"account_move\",\"wallet\":\"#{wallet_id}\",\"source\":\"000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F\",\"accounts\":[\"nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000\",\"nano_5e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000\"]}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"moved": "1"}',
      headers: {}
    )

    wallet = '000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F'
    accounts = [
      'nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000',
      'nano_5e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000'
    ]

    expect(Nanook.new.wallet(wallet_id).move_accounts(wallet, accounts)).to be true
  end

  it 'account remove' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"account_remove\",\"wallet\":\"#{wallet_id}\",\"account\":\"nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"removed": "1"}',
      headers: {}
    )

    account = 'nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000'

    expect(Nanook.new.wallet(wallet_id).remove_account(account)).to be true
  end

  it 'wallet export' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_export\",\"wallet\":\"#{wallet_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"json":"{\\"0000000000000000000000000000000000000000000000000000000000000000\\": \\"0000000000000000000000000000000000000000000000000000000000000001\\"}"}',
      headers: {}
    )

    expect(Nanook.new.wallet(wallet_id).export).to eq '{"0000000000000000000000000000000000000000000000000000000000000000": "0000000000000000000000000000000000000000000000000000000000000001"}'
  end

  it 'wallet history' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_history\",\"wallet\":\"#{wallet_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: <<~BODY,
        {
          "history":
          [
            {
              "type": "send",
              "account": "nano_1qato4k7z3spc8gq1zyd8xeqfbzsoxwo36a45ozbrxcatut7up8ohyardu1z",
              "amount": "30000000000000000000000000000000000",
              "block_account": "nano_1ipx847tk8o46pwxt5qjdbncjqcbwcc1rrmqnkztrfjy5k7z4imsrata9est",
              "hash": "87434F8041869A01C8F6F263B87972D7BA443A72E0A97D7A3FD0CCC2358FD6F9",
              "local_timestamp": "1527698508"
            }
          ]
        }
      BODY
      headers: {}
    )

    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_contains\",\"wallet\":\"#{wallet_id}\",\"account\":\"nano_1qato4k7z3spc8gq1zyd8xeqfbzsoxwo36a45ozbrxcatut7up8ohyardu1z\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"exists":"1"}',
      headers: {}
    )

    response = Nanook.new.wallet(wallet_id).history

    expect(response.first).to eq({
      type: "send",
      account: Nanook.new.wallet(wallet_id).account('nano_1qato4k7z3spc8gq1zyd8xeqfbzsoxwo36a45ozbrxcatut7up8ohyardu1z'),
      amount: 30000.0,
      block_account: Nanook.new.account('nano_1ipx847tk8o46pwxt5qjdbncjqcbwcc1rrmqnkztrfjy5k7z4imsrata9est'),
      block: Nanook.new.block('87434F8041869A01C8F6F263B87972D7BA443A72E0A97D7A3FD0CCC2358FD6F9'),
      local_timestamp: Time.at(1527698508).utc
    })
  end

  it 'wallet search pending' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"search_pending\",\"wallet\":\"#{wallet_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"started":"1"}',
      headers: {}
    )

    expect(Nanook.new.wallet(wallet_id).search_pending).to eq true
  end

  it 'wallet contains? when true' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_contains\",\"wallet\":\"#{wallet_id}\",\"account\":\"#{account_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"exists":"1"}',
      headers: {}
    )

    expect(Nanook.new.wallet(wallet_id).contains?(account_id)).to be true
  end

  it 'wallet contains? when false' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_contains\",\"wallet\":\"#{wallet_id}\",\"account\":\"#{account_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"exists":"0"}',
      headers: {}
    )

    expect(Nanook.new.wallet(wallet_id).contains?(account_id)).to be false
  end

  it 'wallet lock' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_lock\",\"wallet\":\"#{wallet_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"locked":"1"}',
      headers: {}
    )

    expect(Nanook.new.wallet(wallet_id).lock).to be true
  end

  it 'wallet locked? when it is not locked' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_locked\",\"wallet\":\"#{wallet_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"locked":"0"}',
      headers: {}
    )

    expect(Nanook.new.wallet(wallet_id).locked?).to be false
  end

  it 'wallet locked? when it is locked' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_locked\",\"wallet\":\"#{wallet_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"locked":"1"}',
      headers: {}
    )

    expect(Nanook.new.wallet(wallet_id).locked?).to be true
  end

  it 'wallet unlock' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"password_enter\",\"wallet\":\"#{wallet_id}\",\"password\":\"test\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"valid":"1"}',
      headers: {}
    )

    expect(Nanook.new.wallet(wallet_id).unlock('test')).to be true
  end

  it 'wallet change password' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"password_change\",\"wallet\":\"#{wallet_id}\",\"password\":\"test\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"changed":"1"}',
      headers: {}
    )

    expect(Nanook.new.wallet(wallet_id).change_password('test')).to be true
  end

  it 'wallet send payment' do
    stub_valid_account_check

    stub_request(:post, uri).with(
      body: "{\"action\":\"account_info\",\"account\":\"#{account_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"frontier\":\"FF84533A571D953A596EA401FD41743AC85D04F406E76FDE4408EAED50B473C5\",
      \"open_block\":\"991CF190094C00F0B68E2E5F75F6BEE95A2E0BD93CEAA4A6734DB9F19B728948\",
      \"representative_block\":\"991CF190094C00F0B68E2E5F75F6BEE95A2E0BD93CEAA4A6734DB9F19B728948\",
      \"balance\":\"23\",
      \"modified_timestamp\":\"1501793775\",
      \"block_count\":\"33\"}",
      headers: {}
    )

    stub_request(:post, uri).with(
      body: "{\"action\":\"validate_account_number\",\"account\":\"#{account_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"valid":"1"}',
      headers: {}
    )

    stub_request(:post, uri).with(
      body: "{\"action\":\"send\",\"wallet\":\"#{wallet_id}\",\"source\":\"#{account_id}\",\"destination\":\"#{account_id}\",\"amount\":\"2000000000000000000000000000000\",\"id\":\"7081e2b8fec9146e\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"block\":\"#{block_id}\"}",
      headers: {}
    )

    response = Nanook.new.wallet(wallet_id).pay(from: account_id, to: account_id, amount: 2, id: '7081e2b8fec9146e')
    expect(response).to eq Nanook.new.block(block_id)
  end

  it 'wallet send payment in raw' do
    stub_valid_account_check

    stub_request(:post, uri).with(
      body: "{\"action\":\"validate_account_number\",\"account\":\"#{account_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"valid":"1"}',
      headers: {}
    )

    stub_request(:post, uri).with(
      body: "{\"action\":\"account_info\",\"account\":\"#{account_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"frontier\":\"FF84533A571D953A596EA401FD41743AC85D04F406E76FDE4408EAED50B473C5\",
      \"open_block\":\"991CF190094C00F0B68E2E5F75F6BEE95A2E0BD93CEAA4A6734DB9F19B728948\",
      \"representative_block\":\"991CF190094C00F0B68E2E5F75F6BEE95A2E0BD93CEAA4A6734DB9F19B728948\",
      \"balance\":\"23\",
      \"modified_timestamp\":\"1501793775\",
      \"block_count\":\"33\"}",
      headers: {}
    )

    stub_request(:post, uri).with(
      body: "{\"action\":\"send\",\"wallet\":\"#{wallet_id}\",\"source\":\"#{account_id}\",\"destination\":\"#{account_id}\",\"amount\":\"2\",\"id\":\"7081e2b8fec9146e\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"block\":\"#{block_id}\"}",
      headers: {}
    )

    response = Nanook.new.wallet(wallet_id).pay(from: account_id, to: account_id, amount: 2, unit: :raw,
                                                id: '7081e2b8fec9146e')
    expect(response).to eq Nanook.new.block(block_id)
  end

  it 'wallet account receive latest pending payment' do
    stub_valid_account_check

    stub_request(:post, uri).with(
      body: "{\"action\":\"pending\",\"account\":\"#{account_id}\",\"count\":\"1\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"blocks\":[\"#{block_id}\"]}",
      headers: {}
    )

    stub_request(:post, uri).with(
      body: "{\"action\":\"receive\",\"wallet\":\"#{wallet_id}\",\"account\":\"#{account_id}\",\"block\":\"#{block_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"block\":\"#{block_id}\"}",
      headers: {}
    )

    response = Nanook.new.wallet(wallet_id).receive(into: account_id)
    expect(response).to eq Nanook.new.block(block_id)
  end

  it 'wallet account receive latest pending payment when no payment is pending' do
    stub_valid_account_check

    stub_request(:post, uri).with(
      body: "{\"action\":\"pending\",\"account\":\"#{account_id}\",\"count\":\"1\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"blocks":""}',
      headers: {}
    )

    expect(Nanook.new.wallet(wallet_id).receive(into: account_id)).to be false
  end

  it 'wallet account receive payment with block' do
    stub_valid_account_check

    stub_request(:post, uri).with(
      body: "{\"action\":\"receive\",\"wallet\":\"#{wallet_id}\",\"account\":\"#{account_id}\",\"block\":\"#{block_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"block\":\"#{block_id}\"}",
      headers: {}
    )

    response = Nanook.new.wallet(wallet_id).receive(block_id, into: account_id)
    expect(response).to eq Nanook.new.block(block_id)
  end

  it 'wallet balance with account break down' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_balances\",\"wallet\":\"#{wallet_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"balances\":{
        \"nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000\":{
          \"balance\":\"1000000000000000000000000000\",
          \"pending\":\"2000000000000000000000000000\"
        }
      }}",
      headers: {}
    )

    response = Nanook.new.wallet(wallet_id).balance(account_break_down: true)
    expect(response).to have_key :nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000
    expect(response[:nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000][:balance]).to eq(0.001)
    expect(response[:nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000][:pending]).to eq(0.002)
  end

  it 'wallet balance with account break down and unit raw' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_balances\",\"wallet\":\"#{wallet_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"balances\":{
        \"nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000\":{
          \"balance\":\"1000000000000000000000000000\",
          \"pending\":\"2000000000000000000000000000\"
        }
      }}",
      headers: {}
    )

    response = Nanook.new.wallet(wallet_id).balance(account_break_down: true, unit: :raw)
    expect(response).to have_key :nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000
    expect(response[:nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000][:balance]).to eq(1_000_000_000_000_000_000_000_000_000)
    expect(response[:nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000][:pending]).to eq(2_000_000_000_000_000_000_000_000_000)
  end

  it 'wallet balance with no account break down' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_info\",\"wallet\":\"#{wallet_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"balance":"1000000000000000000000000000","pending":"2000000000000000000000000000"}',
      headers: {}
    )

    response = Nanook.new.wallet(wallet_id).balance
    expect(response[:balance]).to eq(0.001)
    expect(response[:pending]).to eq(0.002)
  end

  it 'wallet balance with no account break down in raw' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_info\",\"wallet\":\"#{wallet_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"balance":"1000000000000000000000000000","pending":"2000000000000000000000000000"}',
      headers: {}
    )

    response = Nanook.new.wallet(wallet_id).balance(unit: :raw)
    expect(response[:balance]).to eq(1_000_000_000_000_000_000_000_000_000)
    expect(response[:pending]).to eq(2_000_000_000_000_000_000_000_000_000)
  end

  it 'wallet restore with no accounts' do
    seed = '000F2BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F'

    stub_request(:post, uri).with(
      body: '{"action":"wallet_create"}',
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"wallet\":\"#{wallet_id}\"}",
      headers: {}
    )

    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_change_seed\",\"wallet\":\"#{wallet_id}\",\"seed\":\"#{seed}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"success":""}',
      headers: {}
    )

    response = Nanook.new.wallet.restore(seed)
    expect(response).to be_kind_of Nanook::Wallet
    expect(response.id).to eq wallet_id
  end

  it 'wallet restore with 1 account' do
    seed = '000F2BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F'

    stub_request(:post, uri).with(
      body: '{"action":"wallet_create"}',
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"wallet\":\"#{wallet_id}\"}",
      headers: {}
    )

    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_change_seed\",\"wallet\":\"#{wallet_id}\",\"seed\":\"#{seed}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"success":""}',
      headers: {}
    )

    stub_request(:post, uri).with(
      body: "{\"action\":\"account_create\",\"wallet\":\"#{wallet_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"account":"nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000"}',
      headers: {}
    )

    stub_request(:post, 'http://localhost:7076/')
      .with(
        body: '{"action":"wallet_contains","wallet":"000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F","account":"nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000"}',
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Content-Type' => 'application/json',
          'User-Agent' => 'Ruby nanook gem'
        }
      )
      .to_return(status: 200, body: '{"exists":"1"}', headers: {})

    response = Nanook.new.wallet.restore(seed, accounts: 1)
    expect(response).to be_kind_of Nanook::Wallet
    expect(response.id).to eq wallet_id
  end

  it 'wallet pending with default limit' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_pending\",\"wallet\":\"#{wallet_id}\",\"count\":\"1000\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"blocks\" : {
        \"nano_1111111111111111111111111111111111111111111111111117353trpda\": [\"142A538F36833D1CC78B94E11C766F75818F8B940771335C6C1B8AB880C5BB1D\",\"142A538F36833D1CC78B94E11C766F75818F8B940771335C6C1B8AB880C5BB19\"],
        \"nano_3t6k35gi95xu6tergt6p69ck76ogmitsa8mnijtpxm9fkcm736xtoncuohr3\": [\"4C1FEEF0BEA7F50BE35489A1233FE002B212DEA554B55B1B470D78BD8F210C74\"]
      }}",
      headers: {}
    )

    response = Nanook.new.wallet(wallet_id).pending

    expect(response).to eq(
      Nanook.new.account('nano_1111111111111111111111111111111111111111111111111117353trpda') => [
        Nanook.new.block('142A538F36833D1CC78B94E11C766F75818F8B940771335C6C1B8AB880C5BB1D'),
        Nanook.new.block('142A538F36833D1CC78B94E11C766F75818F8B940771335C6C1B8AB880C5BB19')
      ],
      Nanook.new.account('nano_3t6k35gi95xu6tergt6p69ck76ogmitsa8mnijtpxm9fkcm736xtoncuohr3') => [
        Nanook.new.block('4C1FEEF0BEA7F50BE35489A1233FE002B212DEA554B55B1B470D78BD8F210C74')
      ]
    )
  end

  it 'wallet pending with limit' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_pending\",\"wallet\":\"#{wallet_id}\",\"count\":\"1\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"blocks\": {
        \"nano_1111111111111111111111111111111111111111111111111117353trpda\": [\"142A538F36833D1CC78B94E11C766F75818F8B940771335C6C1B8AB880C5BB1D\",\"142A538F36833D1CC78B94E11C766F75818F8B940771335C6C1B8AB880C5BB19\"]
      }}",
      headers: {}
    )

    response = Nanook.new.wallet(wallet_id).pending(limit: 1)

    expect(response).to eq(
      Nanook.new.account('nano_1111111111111111111111111111111111111111111111111117353trpda') => [
        Nanook.new.block('142A538F36833D1CC78B94E11C766F75818F8B940771335C6C1B8AB880C5BB1D'),
        Nanook.new.block('142A538F36833D1CC78B94E11C766F75818F8B940771335C6C1B8AB880C5BB19')
      ]
    )
  end

  it 'wallet pending with detailed' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_pending\",\"wallet\":\"#{wallet_id}\",\"count\":\"1000\",\"source\":\"true\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"blocks\": {
        \"nano_1111111111111111111111111111111111111111111111111117353trpda\": {
            \"142A538F36833D1CC78B94E11C766F75818F8B940771335C6C1B8AB880C5BB1D\": {
                 \"amount\": \"6000000000000000000000000000000\",
                 \"source\": \"nano_3dcfozsmekr1tr9skf1oa5wbgmxt81qepfdnt7zicq5x3hk65fg4fqj58mbr\"
            },
            \"242A538F36833D1CC78B94E11C766F75818F8B940771335C6C1B8AB880C5BB1D\": {
                 \"amount\": \"12000000000000000000000000000000\",
                 \"source\": \"nano_3dcfozsmekr1tr9skf1oa5wbgmxt81qepfdnt7zicq5x3hk65fg4fqj58mbr\"
            }
        },
        \"nano_3t6k35gi95xu6tergt6p69ck76ogmitsa8mnijtpxm9fkcm736xtoncuohr3\": {
            \"4C1FEEF0BEA7F50BE35489A1233FE002B212DEA554B55B1B470D78BD8F210C74\": {
                 \"amount\": \"106370018000000000000000000000000\",
                 \"source\": \"nano_13ezf4od79h1tgj9aiu4djzcmmguendtjfuhwfukhuucboua8cpoihmh8byo\"
            }
        }
      }}",
      headers: {}
    )

    response = Nanook.new.wallet(wallet_id).pending(detailed: true)

    expect(response.keys).to eq(
      [
        Nanook.new.account('nano_1111111111111111111111111111111111111111111111111117353trpda'),
        Nanook.new.account('nano_3t6k35gi95xu6tergt6p69ck76ogmitsa8mnijtpxm9fkcm736xtoncuohr3'),
      ]
    )
    expect(response[Nanook.new.account('nano_1111111111111111111111111111111111111111111111111117353trpda')]).to eq(
      [
        {
          block: Nanook.new.block('142A538F36833D1CC78B94E11C766F75818F8B940771335C6C1B8AB880C5BB1D'),
          source: Nanook.new.account('nano_3dcfozsmekr1tr9skf1oa5wbgmxt81qepfdnt7zicq5x3hk65fg4fqj58mbr'),
          amount: 6
        },
        {
          block: Nanook.new.block('242A538F36833D1CC78B94E11C766F75818F8B940771335C6C1B8AB880C5BB1D'),
          source: Nanook.new.account('nano_3dcfozsmekr1tr9skf1oa5wbgmxt81qepfdnt7zicq5x3hk65fg4fqj58mbr'),
          amount: 12
        }
      ]
    )
  end

  it 'wallet pending with detailed and unit raw' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_pending\",\"wallet\":\"#{wallet_id}\",\"count\":\"1000\",\"source\":\"true\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"blocks\": {
        \"nano_1111111111111111111111111111111111111111111111111117353trpda\": {
            \"142A538F36833D1CC78B94E11C766F75818F8B940771335C6C1B8AB880C5BB1D\": {
                 \"amount\": \"6000000000000000000000000000000\",
                 \"source\": \"nano_3dcfozsmekr1tr9skf1oa5wbgmxt81qepfdnt7zicq5x3hk65fg4fqj58mbr\"
            },
            \"242A538F36833D1CC78B94E11C766F75818F8B940771335C6C1B8AB880C5BB1D\": {
                 \"amount\": \"12000000000000000000000000000000\",
                 \"source\": \"nano_3dcfozsmekr1tr9skf1oa5wbgmxt81qepfdnt7zicq5x3hk65fg4fqj58mbr\"
            }
        },
        \"nano_3t6k35gi95xu6tergt6p69ck76ogmitsa8mnijtpxm9fkcm736xtoncuohr3\": {
            \"4C1FEEF0BEA7F50BE35489A1233FE002B212DEA554B55B1B470D78BD8F210C74\": {
                 \"amount\": \"106370018000000000000000000000000\",
                 \"source\": \"nano_13ezf4od79h1tgj9aiu4djzcmmguendtjfuhwfukhuucboua8cpoihmh8byo\"
            }
        }
      }}",
      headers: {}
    )

    response = Nanook.new.wallet(wallet_id).pending(detailed: true, unit: :raw)

    expect(response.keys).to eq(
      [
        Nanook.new.account('nano_1111111111111111111111111111111111111111111111111117353trpda'),
        Nanook.new.account('nano_3t6k35gi95xu6tergt6p69ck76ogmitsa8mnijtpxm9fkcm736xtoncuohr3'),
      ]
    )
    expect(response[Nanook.new.account('nano_1111111111111111111111111111111111111111111111111117353trpda')]).to eq(
      [
        {
          block: Nanook.new.block('142A538F36833D1CC78B94E11C766F75818F8B940771335C6C1B8AB880C5BB1D'),
          source: Nanook.new.account('nano_3dcfozsmekr1tr9skf1oa5wbgmxt81qepfdnt7zicq5x3hk65fg4fqj58mbr'),
          amount: 6000000000000000000000000000000
        },
        {
          block: Nanook.new.block('242A538F36833D1CC78B94E11C766F75818F8B940771335C6C1B8AB880C5BB1D'),
          source: Nanook.new.account('nano_3dcfozsmekr1tr9skf1oa5wbgmxt81qepfdnt7zicq5x3hk65fg4fqj58mbr'),
          amount: 12000000000000000000000000000000
        }
      ]
    )
  end

  it 'wallet default_representative' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_representative\",\"wallet\":\"#{wallet_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"representative":"nano_16u1uufyoig8777y6r8iqjtrw8sg8maqrm36zzcm95jmbd9i9aj5i8abr8u5"}',
      headers: {}
    )

    response = Nanook.new.wallet(wallet_id).default_representative

    expect(response).to eq(Nanook.new.account('nano_16u1uufyoig8777y6r8iqjtrw8sg8maqrm36zzcm95jmbd9i9aj5i8abr8u5'))
  end

  it 'wallet change_default_representative' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_representative_set\",\"wallet\":\"#{wallet_id}\",\"representative\":\"#{account_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"set": "1"}',
      headers: {}
    )

    stub_request(:post, uri).with(
      body: "{\"action\":\"account_info\",\"account\":\"#{account_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"frontier\":\"FF84533A571D953A596EA401FD41743AC85D04F406E76FDE4408EAED50B473C5\",
      \"open_block\":\"991CF190094C00F0B68E2E5F75F6BEE95A2E0BD93CEAA4A6734DB9F19B728948\",
      \"representative_block\":\"991CF190094C00F0B68E2E5F75F6BEE95A2E0BD93CEAA4A6734DB9F19B728948\",
      \"balance\":\"23\",
      \"modified_timestamp\":\"1501793775\",
      \"block_count\":\"33\"}",
      headers: {}
    )

    response = Nanook.new.wallet(wallet_id).change_default_representative(account_id)

    expect(response).to eq(Nanook.new.account(account_id))
  end

  it 'wallet ledger' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_ledger\",\"wallet\":\"#{wallet_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: <<~BODY,
        {
          "accounts": {
            "nano_11119gbh8hb4hj1duf7fdtfyf5s75okzxdgupgpgm1bj78ex3kgy7frt3s9n": {
              "frontier": "E71AF3E9DD86BBD8B4620EFA63E065B34D358CFC091ACB4E103B965F95783321",
              "open_block": "643B77F1ECEFBDBE1CC909872964C1DBBE23A6149BD3CEF2B50B76044659B60F",
              "representative_block": "643B77F1ECEFBDBE1CC909872964C1DBBE23A6149BD3CEF2B50B76044659B605",
              "balance": "234375100000000000000000000000000",
              "modified_timestamp": "1511476234",
              "block_count": "2"
            }
          }
        }
      BODY
      headers: {}
    )

    response = Nanook.new.wallet(wallet_id).ledger

    expect(response).to eq(
      Nanook.new.account('nano_11119gbh8hb4hj1duf7fdtfyf5s75okzxdgupgpgm1bj78ex3kgy7frt3s9n') => {
        balance: 234.3751,
        frontier: Nanook.new.block('E71AF3E9DD86BBD8B4620EFA63E065B34D358CFC091ACB4E103B965F95783321'),
        open_block: Nanook.new.block('643B77F1ECEFBDBE1CC909872964C1DBBE23A6149BD3CEF2B50B76044659B60F'),
        representative_block: Nanook.new.block('643B77F1ECEFBDBE1CC909872964C1DBBE23A6149BD3CEF2B50B76044659B605'),
        last_modified_at: Time.at(1511476234),
        block_count: 2
      }
    )
  end

  it 'wallet ledger with unit arg' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_ledger\",\"wallet\":\"#{wallet_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: <<~BODY,
        {
          "accounts": {
            "nano_11119gbh8hb4hj1duf7fdtfyf5s75okzxdgupgpgm1bj78ex3kgy7frt3s9n": {
              "frontier": "E71AF3E9DD86BBD8B4620EFA63E065B34D358CFC091ACB4E103B965F95783321",
              "open_block": "643B77F1ECEFBDBE1CC909872964C1DBBE23A6149BD3CEF2B50B76044659B60F",
              "representative_block": "643B77F1ECEFBDBE1CC909872964C1DBBE23A6149BD3CEF2B50B76044659B605",
              "balance": "234375100000000000000000000000000",
              "modified_timestamp": "1511476234",
              "block_count": "2"
            }
          }
        }
      BODY
      headers: {}
    )

    response = Nanook.new.wallet(wallet_id).ledger(unit: :raw)

    expect(response).to eq(
      Nanook.new.account('nano_11119gbh8hb4hj1duf7fdtfyf5s75okzxdgupgpgm1bj78ex3kgy7frt3s9n') => {
        balance: 234375100000000000000000000000000,
        frontier: Nanook.new.block('E71AF3E9DD86BBD8B4620EFA63E065B34D358CFC091ACB4E103B965F95783321'),
        open_block: Nanook.new.block('643B77F1ECEFBDBE1CC909872964C1DBBE23A6149BD3CEF2B50B76044659B60F'),
        representative_block: Nanook.new.block('643B77F1ECEFBDBE1CC909872964C1DBBE23A6149BD3CEF2B50B76044659B605'),
        last_modified_at: Time.at(1511476234),
        block_count: 2
      }
    )
  end

  it 'wallet info' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_info\",\"wallet\":\"#{wallet_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: <<~BODY,
        {
          "balance": "234375100000000000000000000000000",
          "pending": "134375100000000000000000000000000",
          "accounts_count": "3",
          "adhoc_count": "1",
          "deterministic_count": "4",
          "deterministic_index": "2"
        }
      BODY
      headers: {}
    )

    response = Nanook.new.wallet(wallet_id).info

    expect(response).to eq(
      balance: 234.3751,
      pending: 134.3751,
      accounts_count: 3,
      adhoc_count: 1,
      deterministic_count: 4,
      deterministic_index: 2
    )
  end

  it 'wallet info with raw uni' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"wallet_info\",\"wallet\":\"#{wallet_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: <<~BODY,
        {
          "balance": "234375100000000000000000000000000",
          "pending": "134375100000000000000000000000000",
          "accounts_count": "3",
          "adhoc_count": "1",
          "deterministic_count": "4",
          "deterministic_index": "2"
        }
      BODY
      headers: {}
    )

    response = Nanook.new.wallet(wallet_id).info(unit: :raw)

    expect(response).to eq(
      balance: 234375100000000000000000000000000,
      pending: 134375100000000000000000000000000,
      accounts_count: 3,
      adhoc_count: 1,
      deterministic_count: 4,
      deterministic_index: 2
    )
  end
end
