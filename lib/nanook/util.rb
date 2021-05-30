# frozen_string_literal: true

require 'bigdecimal'

class Nanook
  # Set of utility methods.
  module Util
    # Constant used to convert back and forth between raw and NANO.
    STEP = BigDecimal('10')**BigDecimal('30')

    private

    # Converts an amount of NANO to an amount of raw.
    #
    # @param nano [Float|Integer] amount in nano
    # @return [Integer] amount in raw
    def NANO_to_raw(nano)
      return if nano.nil?

      (BigDecimal(nano.to_s) * STEP).to_i
    end

    # Converts an amount of raw to an amount of NANO.
    #
    # @param raw [Integer] amount in raw
    # @return [Float|Integer] amount in NANO
    def raw_to_NANO(raw)
      return if raw.nil?

      (raw.to_f / STEP).to_f
    end

    # @return [TrueClass] if unit is valid.
    # @raise [Nanook::NanoUnitError] if `unit` is invalid.
    def validate_unit!(unit)
      unless Nanook::UNITS.include?(unit.to_sym)
        raise Nanook::NanoUnitError, "Unit #{unit} must be one of #{Nanook::UNITS}"
      end

      true
    end

    # Returns the +id+ of the object as a short id.
    # See #shorten_id.
    #
    # @return [String]
    def short_id
      shorten_id(id)
    end

    # Returns an id string (hash or nano account) truncated with an ellipsis.
    # The first 7 and last 4 characters are retained for easy identification.
    #
    # ==== Examples:
    #
    #   shorten_id('nano_16u1uufyoig8777y6r8iqjtrw8sg8maqrm36zzcm95jmbd9i9aj5i8abr8u5')
    #     # => "16u1uuf...r8u5"
    #
    #   shorten_id('A170D51B94E00371ACE76E35AC81DC9405D5D04D4CEBC399AEACE07AE05DD293')
    #     # => "A170D51...D293"
    #
    # @return [String]
    def shorten_id(long_id)
      return unless long_id

      [long_id.sub('nano_', '')[0..6], long_id[-4, 4]].join('...')
    end

    def as_account(account_id)
      Nanook::Account.new(@rpc, account_id) if account_id
    end

    def as_wallet_account(account_id, allow_blank: false)
      return unless account_id || allow_blank

      Nanook::WalletAccount.new(@rpc, @wallet, account_id)
    end

    def as_block(block_id)
      Nanook::Block.new(@rpc, block_id) if block_id
    end

    def as_private_key(key, allow_blank: false)
      return unless key || allow_blank

      Nanook::PrivateKey.new(@rpc, key)
    end

    def as_public_key(key)
      Nanook::PublicKey.new(@rpc, key) if key
    end

    def as_time(time)
      Time.at(time).utc if time
    end
  end
end
