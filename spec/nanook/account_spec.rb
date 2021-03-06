# frozen_string_literal: true

RSpec.describe Nanook::Account do
  let(:uri) { Nanook::Rpc::DEFAULT_URI }
  let(:account_id) { 'nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000' }

  it 'can compare equality' do
    account_1 = Nanook.new.account('foo')
    account_2 = Nanook.new.account('foo')
    account_3 = Nanook.new.account('bar')

    expect(account_1).to eq(account_2)
    expect(account_1).not_to eq(account_3)
  end

  it 'can be used as a hash key lookup' do
    hash = {
      Nanook.new.account('foo') => 'found'
    }

    expect(hash[Nanook.new.account('foo')]).to eq('found')
  end

  it 'account blocks' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"account_history\",\"account\":\"#{account_id}\",\"count\":\"1000\",\"reverse\":\"false\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{
        \"history\": [{
                \"hash\": \"000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F\",
                \"type\": \"receive\",
                \"account\": \"nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000\",
                \"amount\": \"100000000000000000000000000000000\"
        }]
    }",
      headers: {}
    )

    expect(Nanook.new.account(account_id).blocks).to eq([
                                                          Nanook.new.block('000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F')
                                                        ])
  end

  it 'account blocks with limit' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"account_history\",\"account\":\"#{account_id}\",\"count\":\"1\",\"reverse\":\"false\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{
        \"history\": [{
                \"hash\": \"000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F\",
                \"type\": \"receive\",
                \"account\": \"nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000\",
                \"amount\": \"100000000000000000000000000000000\"
        }]
    }",
      headers: {}
    )

    expect(Nanook.new.account(account_id).blocks(limit: 1)).to eq([
                                                                    Nanook.new.block('000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F')
                                                                  ])
  end

  it 'account blocks with sorting' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"account_history\",\"account\":\"#{account_id}\",\"count\":\"1000\",\"reverse\":\"true\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{
        \"history\": [{
                \"hash\": \"000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F\",
                \"type\": \"receive\",
                \"account\": \"nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000\",
                \"amount\": \"100000000000000000000000000000000\"
        }]
    }",
      headers: {}
    )

    expect(Nanook.new.account(account_id).blocks(sort: :desc)).to eq([
                                                                       Nanook.new.block('000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F')
                                                                     ])
  end

  it 'open block' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"account_history\",\"account\":\"#{account_id}\",\"count\":\"1\",\"reverse\":\"true\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{
        \"history\": [{
                \"hash\": \"000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F\",
                \"type\": \"receive\",
                \"account\": \"nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000\",
                \"amount\": \"100000000000000000000000000000000\"
        }]
    }",
      headers: {}
    )

    expect(Nanook.new.account(account_id).open_block).to eq(
      Nanook.new.block('000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F')
    )
  end

  it 'account history' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"account_history\",\"account\":\"#{account_id}\",\"count\":\"1000\",\"reverse\":\"false\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{
        \"history\": [{
                \"hash\": \"000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F\",
                \"type\": \"receive\",
                \"account\": \"nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000\",
                \"amount\": \"100000000000000000000000000000000\"
        }]
    }",
      headers: {}
    )

    response = Nanook.new.account(account_id).history

    expect(response).to have(1).item
    expect(response.first).to eq({
                                   block: Nanook.new.block('000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F'),
                                   account: Nanook.new.account('nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000'),
                                   amount: 100.0,
                                   type: 'receive'
                                 })
  end

  it 'account history with sort' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"account_history\",\"account\":\"#{account_id}\",\"count\":\"1000\",\"reverse\":\"true\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{
        \"history\": [{
                \"hash\": \"000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F\",
                \"type\": \"receive\",
                \"account\": \"nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000\",
                \"amount\": \"100000000000000000000000000000000\"
        }]
    }",
      headers: {}
    )

    response = Nanook.new.account(account_id).history(sort: :desc)

    expect(response).to have(1).item
    expect(response.first).to eq({
                                   block: Nanook.new.block('000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F'),
                                   account: Nanook.new.account('nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000'),
                                   amount: 100.0,
                                   type: 'receive'
                                 })
  end

  it 'account history without default count' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"account_history\",\"account\":\"#{account_id}\",\"count\":\"1\",\"reverse\":\"false\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{
        \"history\": [{
                \"hash\": \"000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F\",
                \"type\": \"receive\",
                \"account\": \"nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000\",
                \"amount\": \"100000000000000000000000000000000\"
        }]
    }",
      headers: {}
    )

    response = Nanook.new.account(account_id).history(limit: 1)
    expect(response.first[:amount]).to eq 100
    expect(response).to have(1).item
  end

  it 'account history with raw unit' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"account_history\",\"account\":\"#{account_id}\",\"count\":\"1000\",\"reverse\":\"false\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{
        \"history\": [{
                \"hash\": \"000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F\",
                \"type\": \"receive\",
                \"account\": \"nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000\",
                \"amount\": \"100000000000000000000000000000000\"
        }]
    }",
      headers: {}
    )

    response = Nanook.new.account(account_id).history(unit: :raw)
    expect(response.first[:amount]).to eq 100_000_000_000_000_000_000_000_000_000_000
    expect(response).to have(1).item
  end

  it 'account history when history is blank (unsynced node)' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"account_history\",\"account\":\"#{account_id}\",\"count\":\"1\",\"reverse\":\"false\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"history": ""}',
      headers: {}
    )

    response = Nanook.new.account(account_id).history(limit: 1)
    expect(response).to eq([])
  end

  it 'account public_key' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"account_key\",\"account\":\"#{account_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"key":"3068BB1CA04525BB0E416C485FE6A67FD52540227D267CC8B6E8DA958A7FA039"}',
      headers: {}
    )

    response = Nanook.new.account(account_id).public_key

    expect(response).to be_kind_of(Nanook::PublicKey)
    expect(response.id).to eq '3068BB1CA04525BB0E416C485FE6A67FD52540227D267CC8B6E8DA958A7FA039'
  end

  it 'account balance' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"account_balance\",\"account\":\"#{account_id}\",\"include_only_confirmed\":\"true\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"balance":"11439597000000000000000000000000","pending":"21439597000000000000000000000000"}',
      headers: {}
    )

    response = Nanook.new.account(account_id).balance
    expect(response[:balance]).to eq(11.439597)
    expect(response[:pending]).to eq(21.439597)
  end

  it 'account balance allow_unconfirmed' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"account_balance\",\"account\":\"#{account_id}\",\"include_only_confirmed\":\"false\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"balance":"11439597000000000000000000000000","pending":"21439597000000000000000000000000"}',
      headers: {}
    )

    response = Nanook.new.account(account_id).balance(allow_unconfirmed: true)
    expect(response[:balance]).to eq(11.439597)
    expect(response[:pending]).to eq(21.439597)
  end

  it 'account balance in raw' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"account_balance\",\"account\":\"#{account_id}\",\"include_only_confirmed\":\"true\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"balance":"11439597000000000000000000000000","pending":"21439597000000000000000000000000"}',
      headers: {}
    )

    response = Nanook.new.account(account_id).balance(unit: :raw)
    expect(response[:balance]).to eq(11_439_597_000_000_000_000_000_000_000_000)
    expect(response[:pending]).to eq(21_439_597_000_000_000_000_000_000_000_000)
  end

  it 'account representative' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"account_representative\",\"account\":\"#{account_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"representative":"nano_16u1uufyoig8777y6r8iqjtrw8sg8maqrm36zzcm95jmbd9i9aj5i8abr8u5"}',
      headers: {}
    )

    representative = Nanook.new.account(account_id).representative

    expect(representative).to be_kind_of(Nanook::Account)
    expect(representative.id).to eq('nano_16u1uufyoig8777y6r8iqjtrw8sg8maqrm36zzcm95jmbd9i9aj5i8abr8u5')
  end

  it 'account info' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"account_info\",\"account\":\"#{account_id}\",\"representative\":\"true\",\"weight\":\"true\",\"pending\":\"true\",\"include_confirmed\":\"true\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: <<~BODY,
        {
          "frontier": "80A6745762493FA21A22718ABFA4F635656A707B48B3324198AC7F3938DE6D4F",
          "open_block": "0E3F07F7F2B8AEDEA4A984E29BFE1E3933BA473DD3E27C662EC041F6EA3917A0",
          "representative_block": "80A6745762493FA21A22718ABFA4F635656A707B48B3324198AC7F3938DE6D4F",
          "balance": "10999999999999999918751838129509869131",
          "confirmed_balance": "11999999999999999918751838129509869131",
          "modified_timestamp": "1606934662",
          "block_count": "22966",
          "account_version": "1",
          "confirmed_height": "22956",
          "confirmed_frontier": "10A6745762493FA21A22718ABFA4F635656A707B48B3324198AC7F3938DE6D4F",
          "representative": "nano_2gyeqc6u5j3oaxbe5qy1hyz3q745a318kh8h9ocnpan7fuxnq85cxqboapu5",
          "confirmed_representative": "nano_1gyeqc6u5j3oaxbe5qy1hyz3q745a318kh8h9ocnpan7fuxnq85cxqboapu5",
          "weight": "11999999999999999918751838129509869131",
          "pending": "20000000000000000000000000000000",
          "confirmed_pending": "10000000000000000000000000000000"
        }
      BODY
      headers: {}
    )

    response = Nanook.new.account(account_id).info

    expect(response).to eq({
                             id: account_id,
                             account_version: 1,
                             frontier: Nanook.new.block('10A6745762493FA21A22718ABFA4F635656A707B48B3324198AC7F3938DE6D4F'),
                             open_block: Nanook.new.block('0E3F07F7F2B8AEDEA4A984E29BFE1E3933BA473DD3E27C662EC041F6EA3917A0'),
                             representative_block: Nanook.new.block('80A6745762493FA21A22718ABFA4F635656A707B48B3324198AC7F3938DE6D4F'),
                             confirmation_height: 22956,
                             balance: 12000000.0,
                             last_modified_at: Time.at(1606934662),
                             block_count: 22966,
                             representative: Nanook.new.account('nano_1gyeqc6u5j3oaxbe5qy1hyz3q745a318kh8h9ocnpan7fuxnq85cxqboapu5'),
                             weight: 12000000.0,
                             pending: 10.0
                           })
    expect(response[:last_modified_at].zone).to eq('UTC')
  end

  it 'account info allow_unconfirmed' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"account_info\",\"account\":\"#{account_id}\",\"representative\":\"true\",\"weight\":\"true\",\"pending\":\"true\",\"include_confirmed\":\"false\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: <<~BODY,
        {
          "frontier": "80A6745762493FA21A22718ABFA4F635656A707B48B3324198AC7F3938DE6D4F",
          "open_block": "0E3F07F7F2B8AEDEA4A984E29BFE1E3933BA473DD3E27C662EC041F6EA3917A0",
          "representative_block": "80A6745762493FA21A22718ABFA4F635656A707B48B3324198AC7F3938DE6D4F",
          "balance": "10999999999999999918751838129509869131",
          "modified_timestamp": "1606934662",
          "block_count": "22966",
          "account_version": "1",
          "representative": "nano_2gyeqc6u5j3oaxbe5qy1hyz3q745a318kh8h9ocnpan7fuxnq85cxqboapu5",
          "weight": "11999999999999999918751838129509869131",
          "pending": "20000000000000000000000000000000",
          "confirmation_height": "28",
          "confirmation_height_frontier": "34C70FCA0952E29ADC7BEE6F20381466AE42BD1CFBA4B7DFFE8BD69DF95449EB"
        }
      BODY
      headers: {}
    )

    response = Nanook.new.account(account_id).info(allow_unconfirmed: true)

    expect(response).to eq({
                             id: account_id,
                             account_version: 1,
                             frontier: Nanook.new.block('80A6745762493FA21A22718ABFA4F635656A707B48B3324198AC7F3938DE6D4F'),
                             open_block: Nanook.new.block('0E3F07F7F2B8AEDEA4A984E29BFE1E3933BA473DD3E27C662EC041F6EA3917A0'),
                             representative_block: Nanook.new.block('80A6745762493FA21A22718ABFA4F635656A707B48B3324198AC7F3938DE6D4F'),
                             confirmation_height: 28,
                             confirmation_height_frontier: Nanook.new.block('34C70FCA0952E29ADC7BEE6F20381466AE42BD1CFBA4B7DFFE8BD69DF95449EB'),
                             balance: 11000000.0,
                             last_modified_at: Time.at(1606934662),
                             block_count: 22966,
                             representative: Nanook.new.account('nano_2gyeqc6u5j3oaxbe5qy1hyz3q745a318kh8h9ocnpan7fuxnq85cxqboapu5'),
                             weight: 12000000.0,
                             pending: 20.0
                           })
    expect(response[:last_modified_at].zone).to eq('UTC')
  end

  it 'account info with unit raw' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"account_info\",\"account\":\"#{account_id}\",\"representative\":\"true\",\"weight\":\"true\",\"pending\":\"true\",\"include_confirmed\":\"true\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: <<~BODY,
        {
          "frontier": "80A6745762493FA21A22718ABFA4F635656A707B48B3324198AC7F3938DE6D4F",
          "open_block": "0E3F07F7F2B8AEDEA4A984E29BFE1E3933BA473DD3E27C662EC041F6EA3917A0",
          "representative_block": "80A6745762493FA21A22718ABFA4F635656A707B48B3324198AC7F3938DE6D4F",
          "balance": "10999999999999999918751838129509869131",
          "confirmed_balance": "11999999999999999918751838129509869131",
          "modified_timestamp": "1606934662",
          "block_count": "22966",
          "account_version": "1",
          "confirmed_height": "22956",
          "confirmed_frontier": "10A6745762493FA21A22718ABFA4F635656A707B48B3324198AC7F3938DE6D4F",
          "representative": "nano_2gyeqc6u5j3oaxbe5qy1hyz3q745a318kh8h9ocnpan7fuxnq85cxqboapu5",
          "confirmed_representative": "nano_1gyeqc6u5j3oaxbe5qy1hyz3q745a318kh8h9ocnpan7fuxnq85cxqboapu5",
          "weight": "11999999999999999918751838129509869131",
          "pending": "20000000000000000000000000000000",
          "confirmed_pending": "10000000000000000000000000000000"
        }
      BODY
      headers: {}
    )

    response = Nanook.new.account(account_id).info(unit: :raw)

    expect(response).to include(
      balance: 11999999999999999918751838129509869131,
      pending: 10000000000000000000000000000000,
      weight: 11999999999999999918751838129509869131
    )
  end

  it 'account pending' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"pending\",\"account\":\"#{account_id}\",\"count\":\"1000\",\"sorting\":\"false\",\"include_only_confirmed\":\"true\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"blocks":["000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F"]}',
      headers: {}
    )

    pending = Nanook.new.account(account_id).pending

    expect(pending).to have(1).item
    expect(pending.first).to be_kind_of(Nanook::Block)
    expect(pending.first.id).to eq('000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F')
  end

  it 'account pending with no blocks (empty string response) to be empty' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"pending\",\"account\":\"#{account_id}\",\"count\":\"1000\",\"sorting\":\"false\",\"include_only_confirmed\":\"true\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"blocks":""}',
      headers: {}
    )

    expect(Nanook.new.account(account_id).pending).to eq []
  end

  it 'account pending with limit' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"pending\",\"account\":\"#{account_id}\",\"count\":\"1\",\"sorting\":\"false\",\"include_only_confirmed\":\"true\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"blocks":["000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F"]}',
      headers: {}
    )

    pending = Nanook.new.account(account_id).pending(limit: 1)

    expect(pending.first).to be_kind_of(Nanook::Block)
    expect(pending.first.id).to eq('000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F')
  end

  it 'account pending sorted' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"pending\",\"account\":\"#{account_id}\",\"count\":\"1000\",\"sorting\":\"true\",\"include_only_confirmed\":\"true\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"blocks":["000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F"]}',
      headers: {}
    )

    pending = Nanook.new.account(account_id).pending(sorted: true)

    expect(pending.first).to be_kind_of(Nanook::Block)
    expect(pending.first.id).to eq('000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F')
  end

  it 'account pending allow_unconfirmed' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"pending\",\"account\":\"#{account_id}\",\"count\":\"1000\",\"sorting\":\"false\",\"include_only_confirmed\":\"false\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"blocks":["000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F"]}',
      headers: {}
    )

    pending = Nanook.new.account(account_id).pending(allow_unconfirmed: true)

    expect(pending.first).to be_kind_of(Nanook::Block)
    expect(pending.first.id).to eq('000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F')
  end

  it 'account pending detailed' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"pending\",\"account\":\"#{account_id}\",\"count\":\"1000\",\"sorting\":\"false\",\"include_only_confirmed\":\"true\",\"source\":\"true\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"blocks\":{
        \"000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F\": {
             \"amount\": \"6000000000000000000000000000000\",
             \"source\": \"nano_3dcfozsmekr1tr9skf1oa5wbgmxt81qepfdnt7zicq5x3hk65fg4fqj58mbr\"
        }
    }}",
      headers: {}
    )

    response = Nanook.new.account(account_id).pending(detailed: true)
    expect(response).to have(1).item
    expect(response.first[:source]).to be_kind_of(Nanook::Account)
    expect(response.first[:source].id).to eq 'nano_3dcfozsmekr1tr9skf1oa5wbgmxt81qepfdnt7zicq5x3hk65fg4fqj58mbr'
    expect(response.first[:amount]).to eq 6
    expect(response.first[:block]).to be_kind_of(Nanook::Block)
    expect(response.first[:block].id).to eq '000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F'
  end

  it 'account pending detailed with raw unit' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"pending\",\"account\":\"#{account_id}\",\"count\":\"1000\",\"sorting\":\"false\",\"include_only_confirmed\":\"true\",\"source\":\"true\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"blocks\":{
        \"000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F\": {
             \"amount\": \"6000000000000000000000000000000\",
             \"source\": \"nano_3dcfozsmekr1tr9skf1oa5wbgmxt81qepfdnt7zicq5x3hk65fg4fqj58mbr\"
        }
    }}",
      headers: {}
    )

    response = Nanook.new.account(account_id).pending(detailed: true, unit: :raw)
    expect(response).to have(1).item
    expect(response.first[:source]).to be_kind_of(Nanook::Account)
    expect(response.first[:source].id).to eq 'nano_3dcfozsmekr1tr9skf1oa5wbgmxt81qepfdnt7zicq5x3hk65fg4fqj58mbr'
    expect(response.first[:amount]).to eq 6_000_000_000_000_000_000_000_000_000_000
    expect(response.first[:block]).to be_kind_of(Nanook::Block)
    expect(response.first[:block].id).to eq '000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F'
  end

  it 'account pending detailed with no blocks (empty string response)' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"pending\",\"account\":\"#{account_id}\",\"count\":\"1000\",\"sorting\":\"false\",\"include_only_confirmed\":\"true\",\"source\":\"true\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"blocks":""}',
      headers: {}
    )

    expect(Nanook.new.account(account_id).pending(detailed: true)).to eq([])
  end

  it 'account weight' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"account_weight\",\"account\":\"#{account_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"weight":"1334523434434545666663345345453450"}',
      headers: {}
    )

    expect(Nanook.new.account(account_id).weight).to eq 1334.523434434546
  end

  it 'account weight unit raw' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"account_weight\",\"account\":\"#{account_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"weight":"1334523434434545345345345345666660000000"}',
      headers: {}
    )

    expect(Nanook.new.account(account_id).weight(unit: :raw)).to eq 1_334_523_434_434_545_345_345_345_345_666_660_000_000
  end

  it 'account ledger' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"ledger\",\"account\":\"#{account_id}\",\"count\":\"1000\",\"sorting\":\"false\",\"modified_since\":\"0\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: <<~BODY,
        {
          "accounts": {
            "nano_11119gbh8hb4hj1duf7fdtfyf5s75okzxdgupgpgm1bj78ex3kgy7frt3s9n": {
              "frontier": "E71AF3E9DD86BBD8B4620EFA63E065B34D358CFC091ACB4E103B965F95783321",
              "open_block": "543B77F1ECEFBDBE1CC909872964C1DBBE23A6149BD3CEF2B50B76044659B60F",
              "representative_block": "643B77F1ECEFBDBE1CC909872964C1DBBE23A6149BD3CEF2B50B76044659B60F",
              "balance": "100000000000000000000000000000000",
              "modified_timestamp": "1511476234",
              "block_count": "2",
              "representative": "nano_1anrzcuwe64rwxzcco8dkhpyxpi8kd7zsjc1oeimpc3ppca4mrjtwnqposrs",
              "weight": "2100000000000000000000000000000000",
              "pending": "3100000000000000000000000000000000"
            }
          }
        }
      BODY
      headers: {}
    )

    response = Nanook.new.account(account_id).ledger

    expect(response).to eq(
      Nanook.new.account('nano_11119gbh8hb4hj1duf7fdtfyf5s75okzxdgupgpgm1bj78ex3kgy7frt3s9n') => {
        frontier: Nanook.new.block('E71AF3E9DD86BBD8B4620EFA63E065B34D358CFC091ACB4E103B965F95783321'),
        open_block: Nanook.new.block('543B77F1ECEFBDBE1CC909872964C1DBBE23A6149BD3CEF2B50B76044659B60F'),
        representative_block: Nanook.new.block('643B77F1ECEFBDBE1CC909872964C1DBBE23A6149BD3CEF2B50B76044659B60F'),
        representative: Nanook.new.account('nano_1anrzcuwe64rwxzcco8dkhpyxpi8kd7zsjc1oeimpc3ppca4mrjtwnqposrs'),
        balance: 100.0,
        last_modified_at: Time.at(1_511_476_234),
        block_count: 2,
        weight: 2100.0,
        pending: 3100.0
      }
    )
  end

  it 'account ledger with modified_since' do
    t = Time.now

    stub_request(:post, uri).with(
      body: "{\"action\":\"ledger\",\"account\":\"#{account_id}\",\"count\":\"1000\",\"sorting\":\"false\",\"modified_since\":\"#{t.to_i}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: <<~BODY,
        {
          "accounts": {
            "nano_11119gbh8hb4hj1duf7fdtfyf5s75okzxdgupgpgm1bj78ex3kgy7frt3s9n": {
              "frontier": "E71AF3E9DD86BBD8B4620EFA63E065B34D358CFC091ACB4E103B965F95783321",
              "open_block": "543B77F1ECEFBDBE1CC909872964C1DBBE23A6149BD3CEF2B50B76044659B60F",
              "representative_block": "643B77F1ECEFBDBE1CC909872964C1DBBE23A6149BD3CEF2B50B76044659B60F",
              "balance": "100000000000000000000000000000000",
              "modified_timestamp": "1511476234",
              "block_count": "2",
              "representative": "nano_1anrzcuwe64rwxzcco8dkhpyxpi8kd7zsjc1oeimpc3ppca4mrjtwnqposrs",
              "weight": "2100000000000000000000000000000000",
              "pending": "3100000000000000000000000000000000"
            }
          }
        }
      BODY
      headers: {}
    )

    response = Nanook.new.account(account_id).ledger(modified_since: t)

    expect(response).to eq(
      Nanook.new.account('nano_11119gbh8hb4hj1duf7fdtfyf5s75okzxdgupgpgm1bj78ex3kgy7frt3s9n') => {
        frontier: Nanook.new.block('E71AF3E9DD86BBD8B4620EFA63E065B34D358CFC091ACB4E103B965F95783321'),
        open_block: Nanook.new.block('543B77F1ECEFBDBE1CC909872964C1DBBE23A6149BD3CEF2B50B76044659B60F'),
        representative_block: Nanook.new.block('643B77F1ECEFBDBE1CC909872964C1DBBE23A6149BD3CEF2B50B76044659B60F'),
        representative: Nanook.new.account('nano_1anrzcuwe64rwxzcco8dkhpyxpi8kd7zsjc1oeimpc3ppca4mrjtwnqposrs'),
        balance: 100.0,
        last_modified_at: Time.at(1_511_476_234),
        block_count: 2,
        weight: 2100.0,
        pending: 3100.0
      }
    )
  end

  it 'account ledger with sorting' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"ledger\",\"account\":\"#{account_id}\",\"count\":\"1000\",\"sorting\":\"true\",\"modified_since\":\"0\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: <<~BODY,
        {
          "accounts": {
            "nano_11119gbh8hb4hj1duf7fdtfyf5s75okzxdgupgpgm1bj78ex3kgy7frt3s9n": {
              "frontier": "E71AF3E9DD86BBD8B4620EFA63E065B34D358CFC091ACB4E103B965F95783321",
              "open_block": "543B77F1ECEFBDBE1CC909872964C1DBBE23A6149BD3CEF2B50B76044659B60F",
              "representative_block": "643B77F1ECEFBDBE1CC909872964C1DBBE23A6149BD3CEF2B50B76044659B60F",
              "balance": "100000000000000000000000000000000",
              "modified_timestamp": "1511476234",
              "block_count": "2",
              "representative": "nano_1anrzcuwe64rwxzcco8dkhpyxpi8kd7zsjc1oeimpc3ppca4mrjtwnqposrs",
              "weight": "2100000000000000000000000000000000",
              "pending": "3100000000000000000000000000000000"
            }
          }
        }
      BODY
      headers: {}
    )

    response = Nanook.new.account(account_id).ledger(sort: :desc)

    expect(response).to eq(
      Nanook.new.account('nano_11119gbh8hb4hj1duf7fdtfyf5s75okzxdgupgpgm1bj78ex3kgy7frt3s9n') => {
        frontier: Nanook.new.block('E71AF3E9DD86BBD8B4620EFA63E065B34D358CFC091ACB4E103B965F95783321'),
        open_block: Nanook.new.block('543B77F1ECEFBDBE1CC909872964C1DBBE23A6149BD3CEF2B50B76044659B60F'),
        representative_block: Nanook.new.block('643B77F1ECEFBDBE1CC909872964C1DBBE23A6149BD3CEF2B50B76044659B60F'),
        representative: Nanook.new.account('nano_1anrzcuwe64rwxzcco8dkhpyxpi8kd7zsjc1oeimpc3ppca4mrjtwnqposrs'),
        balance: 100.0,
        last_modified_at: Time.at(1_511_476_234),
        block_count: 2,
        weight: 2100.0,
        pending: 3100.0
      }
    )
  end

  it 'account ledger with limit' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"ledger\",\"account\":\"#{account_id}\",\"count\":\"10\",\"sorting\":\"false\",\"modified_since\":\"0\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: <<~BODY,
        {
          "accounts": {
            "nano_11119gbh8hb4hj1duf7fdtfyf5s75okzxdgupgpgm1bj78ex3kgy7frt3s9n": {
              "frontier": "E71AF3E9DD86BBD8B4620EFA63E065B34D358CFC091ACB4E103B965F95783321",
              "open_block": "543B77F1ECEFBDBE1CC909872964C1DBBE23A6149BD3CEF2B50B76044659B60F",
              "representative_block": "643B77F1ECEFBDBE1CC909872964C1DBBE23A6149BD3CEF2B50B76044659B60F",
              "balance": "100000000000000000000000000000000",
              "modified_timestamp": "1511476234",
              "block_count": "2",
              "representative": "nano_1anrzcuwe64rwxzcco8dkhpyxpi8kd7zsjc1oeimpc3ppca4mrjtwnqposrs",
              "weight": "2100000000000000000000000000000000",
              "pending": "3100000000000000000000000000000000"
            }
          }
        }
      BODY
      headers: {}
    )

    response = Nanook.new.account(account_id).ledger(limit: 10)

    expect(response).to eq(
      Nanook.new.account('nano_11119gbh8hb4hj1duf7fdtfyf5s75okzxdgupgpgm1bj78ex3kgy7frt3s9n') => {
        frontier: Nanook.new.block('E71AF3E9DD86BBD8B4620EFA63E065B34D358CFC091ACB4E103B965F95783321'),
        open_block: Nanook.new.block('543B77F1ECEFBDBE1CC909872964C1DBBE23A6149BD3CEF2B50B76044659B60F'),
        representative_block: Nanook.new.block('643B77F1ECEFBDBE1CC909872964C1DBBE23A6149BD3CEF2B50B76044659B60F'),
        representative: Nanook.new.account('nano_1anrzcuwe64rwxzcco8dkhpyxpi8kd7zsjc1oeimpc3ppca4mrjtwnqposrs'),
        balance: 100.0,
        last_modified_at: Time.at(1_511_476_234),
        block_count: 2,
        weight: 2100.0,
        pending: 3100.0
      }
    )
  end

  it 'account ledger with raw unit' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"ledger\",\"account\":\"#{account_id}\",\"count\":\"1000\",\"sorting\":\"false\",\"modified_since\":\"0\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: <<~BODY,
        {
          "accounts": {
            "nano_11119gbh8hb4hj1duf7fdtfyf5s75okzxdgupgpgm1bj78ex3kgy7frt3s9n": {
              "frontier": "E71AF3E9DD86BBD8B4620EFA63E065B34D358CFC091ACB4E103B965F95783321",
              "open_block": "543B77F1ECEFBDBE1CC909872964C1DBBE23A6149BD3CEF2B50B76044659B60F",
              "representative_block": "643B77F1ECEFBDBE1CC909872964C1DBBE23A6149BD3CEF2B50B76044659B60F",
              "balance": "100000000000000000000000000000000",
              "modified_timestamp": "1511476234",
              "block_count": "2",
              "representative": "nano_1anrzcuwe64rwxzcco8dkhpyxpi8kd7zsjc1oeimpc3ppca4mrjtwnqposrs",
              "weight": "2100000000000000000000000000000000",
              "pending": "3100000000000000000000000000000000"
            }
          }
        }
      BODY
      headers: {}
    )

    response = Nanook.new.account(account_id).ledger(unit: :raw)

    expect(response).to eq(
      Nanook.new.account('nano_11119gbh8hb4hj1duf7fdtfyf5s75okzxdgupgpgm1bj78ex3kgy7frt3s9n') => {
        frontier: Nanook.new.block('E71AF3E9DD86BBD8B4620EFA63E065B34D358CFC091ACB4E103B965F95783321'),
        open_block: Nanook.new.block('543B77F1ECEFBDBE1CC909872964C1DBBE23A6149BD3CEF2B50B76044659B60F'),
        representative_block: Nanook.new.block('643B77F1ECEFBDBE1CC909872964C1DBBE23A6149BD3CEF2B50B76044659B60F'),
        representative: Nanook.new.account('nano_1anrzcuwe64rwxzcco8dkhpyxpi8kd7zsjc1oeimpc3ppca4mrjtwnqposrs'),
        balance: 100_000_000_000_000_000_000_000_000_000_000,
        last_modified_at: Time.at(1_511_476_234),
        block_count: 2,
        weight: 2_100_000_000_000_000_000_000_000_000_000_000,
        pending: 3_100_000_000_000_000_000_000_000_000_000_000
      }
    )
  end

  it 'account exists? when exists' do
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

    expect(Nanook.new.account(account_id).exists?).to be true
  end

  it "account exists? when doesn't exist" do
    stub_request(:post, uri).with(
      body: "{\"action\":\"account_info\",\"account\":\"#{account_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"error":"Bad account number"}',
      headers: {}
    )

    expect(Nanook.new.account(account_id).exists?).to be false
  end

  it 'account delegators' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"delegators\",\"account\":\"#{account_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"delegators\": {
        \"nano_13bqhi1cdqq8yb9szneoc38qk899d58i5rcrgdk5mkdm86hekpoez3zxw5sd\":\"500000000000000000000000000000000000\",
        \"nano_17k6ug685154an8gri9whhe5kb5z1mf5w6y39gokc1657sh95fegm8ht1zpn\":\"961647970820730000000000000000000000\"
      }}",
      headers: {}
    )

    response = Nanook.new.account(account_id).delegators

    expect(response).to eq(
      Nanook.new.account('nano_13bqhi1cdqq8yb9szneoc38qk899d58i5rcrgdk5mkdm86hekpoez3zxw5sd') => 500_000.0,
      Nanook.new.account('nano_17k6ug685154an8gri9whhe5kb5z1mf5w6y39gokc1657sh95fegm8ht1zpn') => 961_647.97082073
    )
  end

  it 'account delegators with unit' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"delegators\",\"account\":\"#{account_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"delegators\": {
        \"nano_13bqhi1cdqq8yb9szneoc38qk899d58i5rcrgdk5mkdm86hekpoez3zxw5sd\":\"500000000000000000000000000000000000\",
        \"nano_17k6ug685154an8gri9whhe5kb5z1mf5w6y39gokc1657sh95fegm8ht1zpn\":\"961647970820730000000000000000000000\"
      }}",
      headers: {}
    )

    response = Nanook.new.account(account_id).delegators(unit: :raw)

    expect(response).to eq(
      Nanook.new.account('nano_13bqhi1cdqq8yb9szneoc38qk899d58i5rcrgdk5mkdm86hekpoez3zxw5sd') => 500_000_000_000_000_000_000_000_000_000_000_000,
      Nanook.new.account('nano_17k6ug685154an8gri9whhe5kb5z1mf5w6y39gokc1657sh95fegm8ht1zpn') => 961_647_970_820_730_000_000_000_000_000_000_000
    )
  end

  it 'account delegators when response is blank (unsynced node)' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"delegators\",\"account\":\"#{account_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"delegators": ""}',
      headers: {}
    )

    response = Nanook.new.account(account_id).delegators
    expect(response).to eq({})
  end

  it 'account last_modified_at' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"account_info\",\"account\":\"#{account_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"frontier\":\"FF84533A571D953A596EA401FD41743AC85D04F406E76FDE4408EAED50B473C5\",
      \"open_block\":\"991CF190094C00F0B68E2E5F75F6BEE95A2E0BD93CEAA4A6734DB9F19B728948\",
      \"representative_block\":\"991CF190094C00F0B68E2E5F75F6BEE95A2E0BD93CEAA4A6734DB9F19B728948\",
      \"balance\":\"23000000000000000000000000000000\",
      \"modified_timestamp\":\"1501793775\",
      \"block_count\":\"33\"}",
      headers: {}
    )

    expect(Nanook.new.account(account_id).last_modified_at).to eq Time.at(1_501_793_775)
  end

  it 'account delegators_count' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"delegators_count\",\"account\":\"#{account_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"count":"2"}',
      headers: {}
    )

    expect(Nanook.new.account(account_id).delegators_count).to eq 2
  end
end
