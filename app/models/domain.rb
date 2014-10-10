class Domain < ActiveRecord::Base
  has_many :link_meta_datas

  require 'uri/http'

  def self.create_if_not_exists url, options = {}
    domain_name = extract_domain_name url
    Rails.logger.info "[DEBUG INFO] domain_name = #{domain_name} - url = #{url}"
    domain = nil
    if domain_name.present?

      domain = Domain.where(:name => domain_name).first

      if domain.blank?
        domain_params = {:name => domain_name}.merge options
        domain = Domain.create(domain_params)
      end
    end
    domain
  end

  def self.extract_domain_name url
    uri = URI.parse(url)
    if PublicSuffix.valid?(uri.host)
      domain = PublicSuffix.parse(uri.host)
      domain.domain
    else
      Rails.logger.info "[DEBUG INFO] not valid uri = #{uri.host} - url = #{url}"
    end
  end
end
