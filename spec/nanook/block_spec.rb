# frozen_string_literal: true

RSpec.describe Nanook::Block do
  let(:uri) { Nanook::Rpc::DEFAULT_URI }
  let(:block) { '000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F' }

  it 'should request account correctly' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"block_account\",\"hash\":\"#{block}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"account":"nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000"}',
      headers: {}
    )

    response = Nanook.new.block(block).account
    expect(response).to be_kind_of Nanook::Account
    expect(response.id).to eq 'nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000'
  end

  it 'should request cancel_work correctly' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"work_cancel\",\"hash\":\"#{block}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{}',
      headers: {}
    )

    expect(Nanook.new.block(block).cancel_work).to be true
  end

  it 'should request chain correctly' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"chain\",\"block\":\"#{block}\",\"count\":\"1000\",\"offset\":\"0\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"blocks":["000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F"]}',
      headers: {}
    )

    expect(Nanook.new.block(block).chain).to have(1).item
  end

  it 'should request chain and when no blocks (empty string response) return an array' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"chain\",\"block\":\"#{block}\",\"count\":\"1000\",\"offset\":\"0\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"blocks":""}',
      headers: {}
    )

    expect(Nanook.new.block(block).chain).to eq []
  end

  it 'should request chain with a limit correctly' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"chain\",\"block\":\"#{block}\",\"count\":\"1\",\"offset\":\"0\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"blocks":["000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F"]}',
      headers: {}
    )

    expect(Nanook.new.block(block).chain(limit: 1)).to have(1).item
  end

  it 'should request chain with an offset correctly' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"chain\",\"block\":\"#{block}\",\"count\":\"1000\",\"offset\":\"1\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"blocks":["000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F"]}',
      headers: {}
    )

    expect(Nanook.new.block(block).chain(offset: 1)).to have(1).item
  end

  it 'should alias ancestors to chain correctly' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"chain\",\"block\":\"#{block}\",\"count\":\"1000\",\"offset\":\"0\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"blocks":["000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F"]}',
      headers: {}
    )

    expect(Nanook.new.block(block).ancestors).to have(1).item
  end

  it 'should request generate_work correctly' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"work_generate\",\"hash\":\"#{block}\",\"use_peers\":\"false\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"work":"2bf29ef00786a6bc"}',
      headers: {}
    )

    expect(Nanook.new.block(block).generate_work).to eq '2bf29ef00786a6bc'
  end

  it 'should request generate_work correctly with optional param user_peers true' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"work_generate\",\"hash\":\"#{block}\",\"use_peers\":\"true\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"work":"2bf29ef00786a6bc"}',
      headers: {}
    )

    expect(Nanook.new.block(block).generate_work(use_peers: true)).to eq '2bf29ef00786a6bc'
  end

  it 'should request block_confirm correctly' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"block_confirm\",\"hash\":\"#{block}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"started":"1"}',
      headers: {}
    )

    expect(Nanook.new.block(block).confirm).to eq true
  end

  it 'should request confirmed_recently? correctly when hash is in confirmation history' do
    stub_request(:post, uri).with(
      body: '{"action":"confirmation_history"}',
      headers: headers
    ).to_return(
      status: 200,
      body: "{
        \"confirmations\": [
          {
            \"hash\": \"#{block}\",
            \"tally\": \"80394786589602980996311817874549318248\"
          },
          {
            \"hash\": \"F2F8DA6D2CA0A4D78EB043A7A29E12BDE5B4CE7DE1B99A93A5210428EE5B8667\",
            \"tally\": \"68921714529890443063672782079965877749\"
          }
        ]
      }",
      headers: {}
    )

    expect(Nanook.new.block(block).confirmed_recently?).to eq true
  end

  it 'should request confirmed_recently? correctly when hash is not in confirmation history' do
    stub_request(:post, uri).with(
      body: '{"action":"confirmation_history"}',
      headers: headers
    ).to_return(
      status: 200,
      body: "{
        \"confirmations\": [
          {
            \"hash\": \"EA70B32C55C193345D625F766EEA2FCA52D3F2CCE0B3A30838CC543026BB0FEA\",
            \"tally\": \"80394786589602980996311817874549318248\"
          },
          {
            \"hash\": \"F2F8DA6D2CA0A4D78EB043A7A29E12BDE5B4CE7DE1B99A93A5210428EE5B8667\",
            \"tally\": \"68921714529890443063672782079965877749\"
          }
        ]
      }",
      headers: {}
    )

    expect(Nanook.new.block(block).confirmed_recently?).to eq false
  end

  it 'should request history correctly' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"history\",\"hash\":\"#{block}\",\"count\":\"1000\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"history\":[{
        \"hash\":\"000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F\",
        \"type\":\"receive\",
        \"account\":\"nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000\",
        \"amount\":\"100000000000000000000000000000000\"
      }]}",
      headers: {}
    )

    expect(Nanook.new.block(block).history).to have(1).item
  end

  it 'should request history with a limit correctly' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"history\",\"hash\":\"#{block}\",\"count\":\"1\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"history\":[{
        \"hash\":\"000D1BAEC8EC208142C99059B393051BAC8380F9B5A2E6B2489A277D81789F3F\",
        \"type\":\"receive\",
        \"account\":\"nano_3e3j5tkog48pnny9dmfzj1r16pg8t1e76dz5tmac6iq689wyjfpi00000000\",
        \"amount\":\"100000000000000000000000000000000\"
      }]}",
      headers: {}
    )

    expect(Nanook.new.block(block).history(limit: 1)).to have(1).item
  end

  it 'should request info correctly' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"block\",\"hash\":\"#{block}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"contents":"{\\n    \\"type\\": \\"receive\\",\\n    \\"previous\\": \\"1B5D8610485FE5E764EA08D4C745B244D9C173647FBFA79C26D3902A439C9688\\",\\n    \\"source\\": \\"F8D4214945C23CB8BD69230A16C85C3ED831CE17107B5C4CC5AA1F68B10EC72C\\",\\n    \\"work\\": \\"633cdda00b9f7265\\",\\n    \\"signature\\": \\"4E5CAAE4556FB2417DE1788B3A5A12B6EFD1811B00A69F4761F0FFD5F9C88FBD653563BDA206753AE3915CA1A4EC804C923DAA3C33580224F138E62805528B06\\"\\n}\\n"}',
      headers: {}
    )

    response = Nanook.new.block(block).info

    expect(response[:id]).to eq block
    expect(response[:type]).to eq 'receive'
    expect(response[:previous]).to eq '1B5D8610485FE5E764EA08D4C745B244D9C173647FBFA79C26D3902A439C9688'
    expect(response[:source]).to eq 'F8D4214945C23CB8BD69230A16C85C3ED831CE17107B5C4CC5AA1F68B10EC72C'
    expect(response[:work]).to eq '633cdda00b9f7265'
    expect(response[:signature]).to eq '4E5CAAE4556FB2417DE1788B3A5A12B6EFD1811B00A69F4761F0FFD5F9C88FBD653563BDA206753AE3915CA1A4EC804C923DAA3C33580224F138E62805528B06'
  end

  it 'should return block not found correctly on info' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"block\",\"hash\":\"#{block}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"error":"Block not found"}',
      headers: {}
    )

    expect(Nanook.new.block(block).info).to have_key(:error)
  end

  it 'should request info allowing_unchecked when block is unchecked correctly' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"unchecked_get\",\"hash\":\"#{block}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"contents":"{\\n    \\"type\\": \\"receive\\",\\n    \\"previous\\": \\"1B5D8610485FE5E764EA08D4C745B244D9C173647FBFA79C26D3902A439C9688\\",\\n    \\"source\\": \\"F8D4214945C23CB8BD69230A16C85C3ED831CE17107B5C4CC5AA1F68B10EC72C\\",\\n    \\"work\\": \\"633cdda00b9f7265\\",\\n    \\"signature\\": \\"4E5CAAE4556FB2417DE1788B3A5A12B6EFD1811B00A69F4761F0FFD5F9C88FBD653563BDA206753AE3915CA1A4EC804C923DAA3C33580224F138E62805528B06\\"\\n}\\n"}',
      headers: {}
    )

    response = Nanook.new.block(block).info(allow_unchecked: true)

    expect(response[:id]).to eq block
    expect(response[:type]).to eq 'receive'
    expect(response[:previous]).to eq '1B5D8610485FE5E764EA08D4C745B244D9C173647FBFA79C26D3902A439C9688'
    expect(response[:source]).to eq 'F8D4214945C23CB8BD69230A16C85C3ED831CE17107B5C4CC5AA1F68B10EC72C'
    expect(response[:work]).to eq '633cdda00b9f7265'
    expect(response[:signature]).to eq '4E5CAAE4556FB2417DE1788B3A5A12B6EFD1811B00A69F4761F0FFD5F9C88FBD653563BDA206753AE3915CA1A4EC804C923DAA3C33580224F138E62805528B06'
  end

  it 'should request info allowing_unchecked when block is not unchecked correctly' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"unchecked_get\",\"hash\":\"#{block}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"error":"Block not found"}',
      headers: {}
    )

    stub_request(:post, uri).with(
      body: "{\"action\":\"block\",\"hash\":\"#{block}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"contents":"{\\n    \\"type\\": \\"receive\\",\\n    \\"previous\\": \\"1B5D8610485FE5E764EA08D4C745B244D9C173647FBFA79C26D3902A439C9688\\",\\n    \\"source\\": \\"F8D4214945C23CB8BD69230A16C85C3ED831CE17107B5C4CC5AA1F68B10EC72C\\",\\n    \\"work\\": \\"633cdda00b9f7265\\",\\n    \\"signature\\": \\"4E5CAAE4556FB2417DE1788B3A5A12B6EFD1811B00A69F4761F0FFD5F9C88FBD653563BDA206753AE3915CA1A4EC804C923DAA3C33580224F138E62805528B06\\"\\n}\\n"}',
      headers: {}
    )

    response = Nanook.new.block(block).info(allow_unchecked: true)

    expect(response[:id]).to eq block
    expect(response[:type]).to eq 'receive'
    expect(response[:previous]).to eq '1B5D8610485FE5E764EA08D4C745B244D9C173647FBFA79C26D3902A439C9688'
    expect(response[:source]).to eq 'F8D4214945C23CB8BD69230A16C85C3ED831CE17107B5C4CC5AA1F68B10EC72C'
    expect(response[:work]).to eq '633cdda00b9f7265'
    expect(response[:signature]).to eq '4E5CAAE4556FB2417DE1788B3A5A12B6EFD1811B00A69F4761F0FFD5F9C88FBD653563BDA206753AE3915CA1A4EC804C923DAA3C33580224F138E62805528B06'
  end

  it 'should request republish correctly' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"republish\",\"hash\":\"#{block}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"blocks\":[
        \"991CF190094C00F0B68E2E5F75F6BEE95A2E0BD93CEAA4A6734DB9F19B728948\",
        \"A170D51B94E00371ACE76E35AC81DC9405D5D04D4CEBC399AEACE07AE05DD293\"
     ]}",
      headers: {}
    )

    expect(Nanook.new.block(block).republish).to have(2).items
  end

  it 'should raise execption if both sources and destinations arguments passed to republish' do
    expect { Nanook.new.block(block).republish(sources: 2, destinations: 2) }.to raise_error(ArgumentError)
  end

  it 'should request republish with sources correctly' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"republish\",\"hash\":\"#{block}\",\"sources\":\"2\",\"count\":\"1\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"blocks\":[
        \"991CF190094C00F0B68E2E5F75F6BEE95A2E0BD93CEAA4A6734DB9F19B728948\",
        \"A170D51B94E00371ACE76E35AC81DC9405D5D04D4CEBC399AEACE07AE05DD293\"
     ]}",
      headers: {}
    )

    expect(Nanook.new.block(block).republish(sources: 2)).to have(2).items
  end

  it 'should request republish with destinations correctly' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"republish\",\"hash\":\"#{block}\",\"destinations\":\"2\",\"count\":\"1\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: "{\"blocks\":[
        \"991CF190094C00F0B68E2E5F75F6BEE95A2E0BD93CEAA4A6734DB9F19B728948\",
        \"A170D51B94E00371ACE76E35AC81DC9405D5D04D4CEBC399AEACE07AE05DD293\"
     ]}",
      headers: {}
    )

    Nanook.new.block(block).republish(destinations: 2)
  end

  it 'should request pending? correctly when block is pending' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"pending_exists\",\"hash\":\"#{block}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"exists":"1"}',
      headers: {}
    )

    expect(Nanook.new.block(block).pending?).to be true
  end

  it 'should request pending? correctly when block is not pending' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"pending_exists\",\"hash\":\"#{block}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"exists":"0"}',
      headers: {}
    )

    expect(Nanook.new.block(block).pending?).to be false
  end

  it 'should request process correctly' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"process\",\"block\":\"#{block}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"hash":"42A723D2B60462BF7C9A003FE9A70057D3A6355CA5F1D0A57581000000000000"}',
      headers: {}
    )

    Nanook.new.block(block).publish
  end

  it 'should request successors correctly' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"successors\",\"block\":\"#{block}\",\"count\":\"1000\",\"offset\":\"0\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"blocks":["A170D51B94E00371ACE76E35AC81DC9405D5D04D4CEBC399AEACE07AE05DD293"]}',
      headers: {}
    )

    expect(Nanook.new.block(block).successors).to have(1).item
  end

  it 'should request successors with limit correctly' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"successors\",\"block\":\"#{block}\",\"count\":\"1\",\"offset\":\"0\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"blocks":["A170D51B94E00371ACE76E35AC81DC9405D5D04D4CEBC399AEACE07AE05DD293"]}',
      headers: {}
    )

    expect(Nanook.new.block(block).successors(limit: 1)).to have(1).item
  end

  it 'should request successors with offset correctly' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"successors\",\"block\":\"#{block}\",\"count\":\"1000\",\"offset\":\"1\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"blocks":["A170D51B94E00371ACE76E35AC81DC9405D5D04D4CEBC399AEACE07AE05DD293"]}',
      headers: {}
    )

    expect(Nanook.new.block(block).successors(offset: 1)).to have(1).item
  end

  it 'should request successors when there are none (empty string response) and return blank array' do
    stub_request(:post, uri).with(
      body: "{\"action\":\"successors\",\"block\":\"#{block}\",\"count\":\"1000\",\"offset\":\"0\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"blocks":""}',
      headers: {}
    )

    expect(Nanook.new.block(block).successors(limit: 1000)).to be_empty
  end

  it 'should request is_valid_work? correctly when valid' do
    work = '2bf29ef00786a6bc'

    stub_request(:post, uri).with(
      body: "{\"action\":\"work_validate\",\"hash\":\"#{block}\",\"work\":\"#{work}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"valid":"1"}',
      headers: {}
    )

    expect(Nanook.new.block(block).is_valid_work?(work)).to be true
  end

  it 'should request is_valid_work? correctly when not valid' do
    work = '2bf29ef00786a6bc'

    stub_request(:post, uri).with(
      body: "{\"action\":\"work_validate\",\"hash\":\"#{block}\",\"work\":\"#{work}\"}",
      headers: headers
    ).to_return(
      status: 200,
      body: '{"valid":"0"}',
      headers: {}
    )

    expect(Nanook.new.block(block).is_valid_work?(work)).to be false
  end
end
