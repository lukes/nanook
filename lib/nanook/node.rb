# frozen_string_literal: true

require_relative 'util'

class Nanook
  # The <tt>Nanook::Node</tt> class contains methods to manage your nano
  # node and query its data of the nano network.
  #
  # Your node is constantly syncing data with other nodes on the network. When
  # your node first starts up after being built, its database will be empty
  # and it will begin synchronizing and downloading data of the nano ledger
  # to its local database. The ledger is the central record of all accounts
  # and transactions. Some of the methods in this class query your node's
  # database formed from the nano ledger, and so the responses are determined
  # by the completeness of your node's database.
  #
  # You can determine how synchronized your node is with the nano ledger
  # with the {#sync_progress} method.
  #
  # === Initializing
  #
  # Initialize this class through the convenient {Nanook#node} method:
  #
  #   node = Nanook.new.node
  #
  # Or compose the longhand way like this:
  #
  #   rpc_conn = Nanook::Rpc.new
  #   node = Nanook::Node.new(rpc_conn)
  class Node
    include Nanook::Util

    def initialize(rpc)
      @rpc = rpc
    end

    # The number of accounts in the nano ledger--essentially all
    # accounts with _open_ blocks. An _open_ block
    # is the type of block written to the nano ledger when an account
    # receives its first payment (see {Nanook::WalletAccount#receive}). All accounts
    # that respond +true+ to {Nanook::Account#exists?} have open blocks in the ledger.
    #
    # @return [Integer] number of accounts with _open_ blocks.
    def account_count
      rpc(:frontier_count)[:count]
    end
    alias frontier_count account_count

    # The count of all blocks downloaded to the node, and
    # blocks still to be synchronized by the node.
    #
    # ==== Example:
    #
    #   {
    #     count: 100,
    #     unchecked: 10,
    #     cemented: 25
    #   }
    #
    # @return [Hash{Symbol=>Integer}] number of blocks and unchecked
    #   synchronizing blocks
    def block_count
      rpc(:block_count)
    end

    # Tells the node to send a keepalive packet to a specific IP address and port.
    #
    # @return [Boolean] indicating if the action was successful
    def keepalive(address:, port:)
      rpc(:keepalive, address: address, port: port).key?(:started)
    end

    # Initialize bootstrap to a specific IP address and port.
    #
    # @return [Boolean] indicating if the action was successful
    def bootstrap(address:, port:)
      rpc(:bootstrap, address: address, port: port).key?(:success)
    end

    # Initialize multi-connection bootstrap to random peers
    #
    # @return [Boolean] indicating if the action was successful
    def bootstrap_any
      rpc(:bootstrap_any).key?(:success)
    end

    # Initialize lazy bootstrap with given block hash
    #
    # @param hash [String]
    # @param force [Boolean] False by default. Manually force closing
    #   of all current bootstraps
    # @return [Boolean] indicating if the action was successful
    def bootstrap_lazy(hash, force: false)
      rpc(:bootstrap_lazy, hash: hash, force: force)[:started] == 1
    end

    # Returns information about node elections settings and observed network state:
    #
    # - `quorum_delta`: delta tally required to rollback block
    # - `online_weight_quorum_percent`: percentage of online weight for delta
    # - `online_weight_minimum`: minimum online weight to confirm block
    # - `online_stake_total`: currently observed online total weight
    # - `peers_stake_total`: known peers total weight
    # - `peers_stake_required`: effective stake needed from directly connected peers for quorum
    #
    # ==== Example:
    #
    #   node.confirmation_quorum
    #
    # Example response:
    #
    #   {
    #     "quorum_delta": 43216377.43025059,
    #     "online_weight_quorum_percent": 50,
    #     "online_weight_minimum": 60000000.0",
    #     "online_stake_total": 86432754.86050119,
    #     "peers_stake_total": 84672338.52479072,
    #     "peers_stake_required": 60000000.0"
    #   }
    #
    # @return [Hash{Symbol=>String|Integer}]
    # @raise [Nanook::NanoUnitError] if `unit` is invalid
    def confirmation_quorum(unit: Nanook.default_unit)
      validate_unit!(unit)

      response = rpc(:confirmation_quorum, _coerce: Hash)

      return response unless unit == :nano

      response[:quorum_delta] = raw_to_NANO(response[:quorum_delta])
      response[:online_weight_minimum] = raw_to_NANO(response[:online_weight_minimum])
      response[:online_stake_total] = raw_to_NANO(response[:online_stake_total])
      response[:peers_stake_total] = raw_to_NANO(response[:peers_stake_total])
      response[:peers_stake_required] = raw_to_NANO(response[:peers_stake_required])

      response.compact
    end

    # Returns the difficulty values (16 hexadecimal digits string, 64 bit)
    # for the minimum required on the network (network_minimum) as well
    # as the current active difficulty seen on the network (network_current,
    # 5 minute trended average of adjusted difficulty seen on confirmed
    # transactions) which can be used to perform rework for better
    # prioritization of transaction processing. A multiplier of the
    # network_current from the base difficulty of network_minimum is also
    # provided for comparison.
    #
    # ==== Example:
    #
    #   node.difficulty(include_trend: true)
    #
    # Example response:
    #
    #   {
    #     network_minimum: "ffffffc000000000",
    #     network_current: "ffffffc1816766f2",
    #     multiplier: 1.024089858417128,
    #     difficulty_trend: [
    #       1.156096135149775,
    #       1.190133894573061,
    #       1.135567138563921,
    #       1.000000000000000,
    #     ]
    #   }
    #
    # @param include_trend [Boolean] false by default. Also returns the
    #   trend of difficulty seen on the network as a list of multipliers.
    #   Sampling occurs every 16 to 36 seconds. The list is ordered such
    #   that the first value is the most recent sample.
    # @return [Hash{Symbol=>String|Float|Array}]
    def difficulty(include_trend: false)
      rpc(:active_difficulty, include_trend: include_trend).tap do |response|
        response[:multiplier] = response[:multiplier].to_f

        response[:difficulty_trend].map!(&:to_f) if response.key?(:difficulty_trend)
      end
    end

    # @return [String]
    def inspect
      "#{self.class.name}(object_id: \"#{format('0x00%x', (object_id << 1))}\")"
    end

    # Returns peers information.
    #
    # Example response:
    #
    #   {
    #     :"[::ffff:104.131.102.132]:7075" => {
    #       protocol_version: 20,
    #       node_id: "node_1y7j5rdqhg99uyab1145gu3yur1ax35a3b6qr417yt8cd6n86uiw3d4whty3",
    #       type: "udp"
    #     },
    #     :"[::ffff:104.131.114.102]:7075" => { ... }
    #   }
    #
    # @return [Hash{Symbol=>Hash{Symbol=>Integer|String}}]
    def peers
      rpc(:peers, peer_details: true)[:peers]
    end

    # All representatives and their voting weight.
    #
    # ==== Example:
    #
    #   node.representatives
    #
    # Example response:
    #
    #   {
    #     nano_1111111111111111111111111111111111111111111111111117353trpda: 3822372327060170000000000000000000000,
    #     nano_1111111111111111111111111111111111111111111111111awsq94gtecn: 30999999999999999999999999000000,
    #     nano_114nk4rwjctu6n6tr6g6ps61g1w3hdpjxfas4xj1tq6i8jyomc5d858xr1xi: 0
    #   }
    #
    # @return [Hash{Symbol=>Float|Integer}] known representatives and their voting weight
    # @raise [Nanook::NanoUnitError] if `unit` is invalid
    def representatives(unit: Nanook.default_unit)
      Nanook.validate_unit!(unit)

      response = rpc(:representatives)[:representatives]
      return response if unit == :raw

      r = response.map do |account_id, weight|
        weight = raw_to_NANO(weight)

        [account_id, weight]
      end

      Hash[r].to_symbolized_hash
    end

    # All online representatives that have voted recently and their weight.
    #
    # ==== Example:
    #
    #   node.representatives_online # => ["nano_111...", "nano_222"]
    #
    # @return [Array<String>] array of representative account ids
    def representatives_online
      rpc(:representatives_online)[:representatives].map(&:to_s)
    end

    # Tells the node to look for any account in all available wallets.
    #
    # ==== Example:
    #
    #   node.search_pending #=> true
    # @return [Boolean] indicates if the action was successful
    def search_pending
      rpc(:search_pending_all).key?(:success)
    end

    # Safely shuts down the node.
    #
    # @return [Boolean] indicating if action was successful
    def stop
      rpc(:stop).key?(:success)
    end

    # @param limit [Integer] number of synchronizing blocks to return
    # @return [Hash{Symbol=>String}] information about the synchronizing blocks for this node
    def synchronizing_blocks(limit: 1000)
      response = rpc(:unchecked, count: limit)[:blocks]
      response = response.map do |block, info|
        [block, JSON.parse(info).to_symbolized_hash]
      end
      Hash[response.sort].to_symbolized_hash
    end
    alias unchecked synchronizing_blocks

    # The percentage completeness of the synchronization process for
    # your node as it downloads the nano ledger. Note, it's normal for
    # your progress to not ever reach 100. The closer to 100, the more
    # complete your node's data is, and so the query methods in this class
    # become more reliable.
    #
    # @return [Float] the percentage completeness of the synchronization
    #   process for your node
    def sync_progress
      response = rpc(:block_count)

      count = response[:count]
      unchecked = response[:unchecked]
      total = count + unchecked

      count.to_f * 100 / total.to_f
    end

    # Returns node uptime in seconds
    #
    # @return [Integer] seconds of uptime
    def uptime
      rpc(:uptime)['seconds']
    end

    # Sets the receive minimum for wallets on the node. The value is in +Nano+ by default.
    # To specify an amount in +raw+, pass the argument +unit: :raw+.
    #
    # ==== Example:
    #
    #   account.change_receive_minimum(0.01) # true
    #
    # @return [Boolean] true if the action was successful
    # @param minimum Amount to set as the receive minimum
    # @param unit optional. Specify +raw+ if you want to set the amount in +raw+. (See Nanook::Account#balance)
    # @raise [Nanook::NanoUnitError] if `unit` is invalid
    def change_receive_minimum(minimum, unit: Nanook.default_unit)
      validate_unit!(unit)

      minimum = NANO_to_raw(minimum) if unit == :nano

      rpc(:receive_minimum_set, amount: minimum).key?(:success)
    end

    # Returns receive minimum for wallets on the node.
    #
    # ==== Example:
    #
    #   account.receive_minimum # => 0.01
    #
    # @return [Integer|Float] the receive minimum
    # @param unit (see Nanook::Account#balance)
    # @raise [Nanook::NanoUnitError] if `unit` is invalid
    def receive_minimum(unit: Nanook.default_unit)
      validate_unit!(unit)

      amount = rpc(:receive_minimum)[:amount]

      return amount unless unit == :nano

      raw_to_NANO(amount)
    end

    # @return [Hash{Symbol=>Integer|String}] version information for this node
    def version
      rpc(:version)
    end
    alias info version

    private

    def rpc(action, params = {})
      @rpc.call(action, params)
    end
  end
end
