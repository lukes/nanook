# frozen_string_literal: true

RSpec.describe Nanook::Account do
  let(:uri) { Nanook::Rpc::DEFAULT_URI }
  let(:account_id) { 'nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000' }

  it 'account history' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"account_history\",\"account\":\"#{account_id}\",\"count\":\"1000\"}",
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
    expect(response.first[:amount]).to eq 100
    expect(response).to have(1).item
  end

  it 'account history without default count' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"account_history\",\"account\":\"#{account_id}\",\"count\":\"1\"}",
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
      body: "{\"action\":\"account_history\",\"account\":\"#{account_id}\",\"count\":\"1000\"}",
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
      body: "{\"action\":\"account_history\",\"account\":\"#{account_id}\",\"count\":\"1\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"history\": \"\"}",
      headers: {}
    )

    response = Nanook.new.account(account_id).history(limit: 1)
    expect(response).to eq([])
  end

  it 'account key' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"account_key\",\"account\":\"#{account_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"key":"3068BB1CA04525BB0E416C485FE6A67FD52540227D267CC8B6E8DA958A7FA039"}',
      headers: {}
    )

    expect(Nanook.new.account(account_id).public_key).to eq '3068BB1CA04525BB0E416C485FE6A67FD52540227D267CC8B6E8DA958A7FA039'
  end

  it 'account balance' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"account_balance\",\"account\":\"#{account_id}\"}",
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

  it 'account balance in raw' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"account_balance\",\"account\":\"#{account_id}\"}",
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

    expect(Nanook.new.account(account_id).representative).to eq 'nano_16u1uufyoig8777y6r8iqjtrw8sg8maqrm36zzcm95jmbd9i9aj5i8abr8u5'
  end

  it 'account info' do
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

    response = Nanook.new.account(account_id).info

    expect(response[:id]).to eq account_id
    expect(response[:frontier]).to eq 'FF84533A571D953A596EA401FD41743AC85D04F406E76FDE4408EAED50B473C5'
    expect(response[:open_block]).to eq '991CF190094C00F0B68E2E5F75F6BEE95A2E0BD93CEAA4A6734DB9F19B728948'
    expect(response[:representative_block]).to eq '991CF190094C00F0B68E2E5F75F6BEE95A2E0BD93CEAA4A6734DB9F19B728948'
    expect(response[:balance]).to eq 23
    expect(response[:modified_timestamp]).to eq 1_501_793_775
    expect(response[:block_count]).to eq 33
  end

  it 'account info with unit raw' do
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

    response = Nanook.new.account(account_id).info(unit: :raw)
    expect(response[:balance]).to eq 23_000_000_000_000_000_000_000_000_000_000
  end

  it 'account info with detailed true' do
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

    stub_request(:post, 'http://localhost:7076/')
      .with(
        body: '{"action":"account_weight","account":"nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000"}',
        headers: headers
      )
      .to_return(status: 200, body: '{"weight":"1"}', headers: {})

    stub_request(:post, uri).with(
      body: "{\"action\":\"account_balance\",\"account\":\"#{account_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"balance":"10000","pending":"12323434523432343245645645645645"}',
      headers: {}
    )

    stub_request(:post, uri).with(
      body: "{\"action\":\"account_representative\",\"account\":\"#{account_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"representative":"nano_16u1uufyoig8777y6r8iqjtrw8sg8maqrm36zzcm95jmbd9i9aj5i8abr8u5"}',
      headers: {}
    )

    stub_request(:post, uri).with(
      body: "{\"action\":\"account_key\",\"account\":\"#{account_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"key":"3068BB1CA04525BB0E416C485FE6A67FD52540227D267CC8B6E8DA958A7FA039"}',
      headers: {}
    )

    response = Nanook.new.account(account_id).info(detailed: true)

    expect(response[:id]).to eq account_id
    expect(response[:frontier]).to eq 'FF84533A571D953A596EA401FD41743AC85D04F406E76FDE4408EAED50B473C5'
    expect(response[:open_block]).to eq '991CF190094C00F0B68E2E5F75F6BEE95A2E0BD93CEAA4A6734DB9F19B728948'
    expect(response[:representative_block]).to eq '991CF190094C00F0B68E2E5F75F6BEE95A2E0BD93CEAA4A6734DB9F19B728948'
    expect(response[:balance]).to eq 23
    expect(response[:pending]).to eq 12.32343452343234
    expect(response[:modified_timestamp]).to eq 1_501_793_775
    expect(response[:block_count]).to eq 33
    expect(response[:weight]).to eq 1
    expect(response[:representative]).to eq 'nano_16u1uufyoig8777y6r8iqjtrw8sg8maqrm36zzcm95jmbd9i9aj5i8abr8u5'
    expect(response[:public_key]).to eq '3068BB1CA04525BB0E416C485FE6A67FD52540227D267CC8B6E8DA958A7FA039'
  end

  it 'account info with detailed true and unit raw' do
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

    stub_request(:post, 'http://localhost:7076/')
      .with(
        body: '{"action":"account_weight","account":"nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000"}',
        headers: headers
      )
      .to_return(status: 200, body: '{"weight":"1"}', headers: {})

    stub_request(:post, uri).with(
      body: "{\"action\":\"account_balance\",\"account\":\"#{account_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"balance":"10000","pending":"12323434523432343245645645645645"}',
      headers: {}
    )

    stub_request(:post, uri).with(
      body: "{\"action\":\"account_representative\",\"account\":\"#{account_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"representative":"nano_16u1uufyoig8777y6r8iqjtrw8sg8maqrm36zzcm95jmbd9i9aj5i8abr8u5"}',
      headers: {}
    )

    stub_request(:post, uri).with(
      body: "{\"action\":\"account_key\",\"account\":\"#{account_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"key":"3068BB1CA04525BB0E416C485FE6A67FD52540227D267CC8B6E8DA958A7FA039"}',
      headers: {}
    )

    response = Nanook.new.account(account_id).info(detailed: true, unit: :raw)
    expect(response[:balance]).to eq 23_000_000_000_000_000_000_000_000_000_000
    expect(response[:pending]).to eq 12_323_434_523_432_343_245_645_645_645_645
  end

  it 'account pending no limit' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"pending\",\"account\":\"#{account_id}\",\"count\":\"1000\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"blocks":["000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F"]}',
      headers: {}
    )

    expect(Nanook.new.account(account_id).pending).to have(1).item
  end

  it 'account pending with no blocks (empty string response) to be empty' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"pending\",\"account\":\"#{account_id}\",\"count\":\"1000\"}",
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
      body: "{\"action\":\"pending\",\"account\":\"#{account_id}\",\"count\":\"1\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"blocks":["000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F"]}',
      headers: {}
    )

    expect(Nanook.new.account(account_id).pending(limit: 1)).to have(1).item
  end

  it 'account pending detailed' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"pending\",\"account\":\"#{account_id}\",\"count\":\"1000\",\"source\":\"true\"}",
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
    expect(response.first[:source]).to eq 'nano_3dcfozsmekr1tr9skf1oa5wbgmxt81qepfdnt7zicq5x3hk65fg4fqj58mbr'
    expect(response.first[:amount]).to eq 6
    expect(response.first[:block]).to eq '000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F'
  end

  it 'account pending detailed with raw unit' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"pending\",\"account\":\"#{account_id}\",\"count\":\"1000\",\"source\":\"true\"}",
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
    expect(response.first[:source]).to eq 'nano_3dcfozsmekr1tr9skf1oa5wbgmxt81qepfdnt7zicq5x3hk65fg4fqj58mbr'
    expect(response.first[:amount]).to eq 6_000_000_000_000_000_000_000_000_000_000
    expect(response.first[:block]).to eq '000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F'
  end

  it 'account pending detailed with no blocks (empty string response)' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"pending\",\"account\":\"#{account_id}\",\"count\":\"1000\",\"source\":\"true\"}",
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
      body: '{"weight":"10000"}',
      headers: {}
    )

    expect(Nanook.new.account(account_id).weight).to eq 10_000
  end

  it 'account ledger' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"ledger\",\"account\":\"#{account_id}\",\"count\":\"1\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"accounts\": {
        \"nano_11119gbh8hb4hj1duf7fdtfyf5s75okzxdgupgpgm1bj78ex3kgy7frt3s9n\": {
          \"frontier\": \"E71AF3E9DD86BBD8B4620EFA63E065B34D358CFC091ACB4E103B965F95783321\",
          \"open_block\": \"643B77F1ECEFBDBE1CC909872964C1DBBE23A6149BD3CEF2B50B76044659B60F\",
          \"representative_block\": \"643B77F1ECEFBDBE1CC909872964C1DBBE23A6149BD3CEF2B50B76044659B60F\",
          \"balance\": \"100000000000000000000000000000000\",
          \"modified_timestamp\": \"1511476234\",
          \"block_count\": \"2\"
        }
      } }",
      headers: {}
    )

    response = Nanook.new.account(account_id).ledger
    expect(response).to have_key(:nano_11119gbh8hb4hj1duf7fdtfyf5s75okzxdgupgpgm1bj78ex3kgy7frt3s9n)
    expect(response[:nano_11119gbh8hb4hj1duf7fdtfyf5s75okzxdgupgpgm1bj78ex3kgy7frt3s9n][:balance]).to eq(100)
  end

  it 'account ledger with modified_since' do
    t = Time.now

    stub_request(:post, uri).with(
      body: "{\"action\":\"ledger\",\"account\":\"#{account_id}\",\"count\":\"1\",\"modified_since\":\"#{t.to_i}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"accounts\": {
        \"nano_11119gbh8hb4hj1duf7fdtfyf5s75okzxdgupgpgm1bj78ex3kgy7frt3s9n\": {
          \"frontier\": \"E71AF3E9DD86BBD8B4620EFA63E065B34D358CFC091ACB4E103B965F95783321\",
          \"open_block\": \"643B77F1ECEFBDBE1CC909872964C1DBBE23A6149BD3CEF2B50B76044659B60F\",
          \"representative_block\": \"643B77F1ECEFBDBE1CC909872964C1DBBE23A6149BD3CEF2B50B76044659B60F\",
          \"balance\": \"100000000000000000000000000000000\",
          \"modified_timestamp\": \"1511476234\",
          \"block_count\": \"2\"
        }
      } }",
      headers: {}
    )

    response = Nanook.new.account(account_id).ledger(modified_since: t)
    expect(response).to have_key(:nano_11119gbh8hb4hj1duf7fdtfyf5s75okzxdgupgpgm1bj78ex3kgy7frt3s9n)
    expect(response[:nano_11119gbh8hb4hj1duf7fdtfyf5s75okzxdgupgpgm1bj78ex3kgy7frt3s9n][:balance]).to eq(100)
  end

  it 'account ledger with limit' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"ledger\",\"account\":\"#{account_id}\",\"count\":\"10\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"accounts\": {
        \"nano_11119gbh8hb4hj1duf7fdtfyf5s75okzxdgupgpgm1bj78ex3kgy7frt3s9n\": {
          \"frontier\": \"E71AF3E9DD86BBD8B4620EFA63E065B34D358CFC091ACB4E103B965F95783321\",
          \"open_block\": \"643B77F1ECEFBDBE1CC909872964C1DBBE23A6149BD3CEF2B50B76044659B60F\",
          \"representative_block\": \"643B77F1ECEFBDBE1CC909872964C1DBBE23A6149BD3CEF2B50B76044659B60F\",
          \"balance\": \"100000000000000000000000000000000\",
          \"modified_timestamp\": \"1511476234\",
          \"block_count\": \"2\"
        }
      } }",
      headers: {}
    )

    response = Nanook.new.account(account_id).ledger(limit: 10)
    expect(response).to have_key(:nano_11119gbh8hb4hj1duf7fdtfyf5s75okzxdgupgpgm1bj78ex3kgy7frt3s9n)
  end

  it 'account ledger with raw unit' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"ledger\",\"account\":\"#{account_id}\",\"count\":\"1\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"accounts\": {
        \"nano_11119gbh8hb4hj1duf7fdtfyf5s75okzxdgupgpgm1bj78ex3kgy7frt3s9n\": {
          \"frontier\": \"E71AF3E9DD86BBD8B4620EFA63E065B34D358CFC091ACB4E103B965F95783321\",
          \"open_block\": \"643B77F1ECEFBDBE1CC909872964C1DBBE23A6149BD3CEF2B50B76044659B60F\",
          \"representative_block\": \"643B77F1ECEFBDBE1CC909872964C1DBBE23A6149BD3CEF2B50B76044659B60F\",
          \"balance\": \"100000000000000000000000000000000\",
          \"modified_timestamp\": \"1511476234\",
          \"block_count\": \"2\"
        }
      } }",
      headers: {}
    )

    response = Nanook.new.account(account_id).ledger(unit: :raw)
    expect(response).to have_key(:nano_11119gbh8hb4hj1duf7fdtfyf5s75okzxdgupgpgm1bj78ex3kgy7frt3s9n)
    expect(response[:nano_11119gbh8hb4hj1duf7fdtfyf5s75okzxdgupgpgm1bj78ex3kgy7frt3s9n][:balance]).to eq 100_000_000_000_000_000_000_000_000_000_000
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
    expect(response).to have_key(:nano_13bqhi1cdqq8yb9szneoc38qk899d58i5rcrgdk5mkdm86hekpoez3zxw5sd)
    expect(response[:nano_13bqhi1cdqq8yb9szneoc38qk899d58i5rcrgdk5mkdm86hekpoez3zxw5sd]).to eq(500_000)
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
    expect(response).to have_key(:nano_13bqhi1cdqq8yb9szneoc38qk899d58i5rcrgdk5mkdm86hekpoez3zxw5sd)
    expect(response[:nano_13bqhi1cdqq8yb9szneoc38qk899d58i5rcrgdk5mkdm86hekpoez3zxw5sd]).to eq(500_000_000_000_000_000_000_000_000_000_000_000)
  end

  it 'account delegators when response is blank (unsynced node)' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"delegators\",\"account\":\"#{account_id}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"delegators\": \"\"}",
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
end
