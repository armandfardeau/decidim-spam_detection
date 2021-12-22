# frozen_string_literal: true

require "uri"
require "net/http"

module Decidim
  module SpamDetection
    class ReportSpamUserCommand < Decidim::SpamDetection::AbstractSpamUserCommand
      prepend Decidim::SpamDetection::Command

      def self.call(user, probability)
        new(user, probability).call
      end

      def call
        form = form(Decidim::ReportForm).from_params(
          reason: "spam",
          details: "The user was marked as spam by Decidim spam detection bot"
        )

        current_organization = @user.organization
        moderator = @moderator
        user = @user

        report = Decidim::CreateUserReport.new(form, user, moderator)
        report.define_singleton_method(:current_organization) { current_organization }
        report.define_singleton_method(:current_user) { moderator }
        report.define_singleton_method(:reportable) { user }
        report.call

        add_spam_detection_metadata!({
                                       "reported_at" => Time.current,
                                       "spam_probability" => @probability
                                     })

        Rails.logger.info("User with id #{user.id} was reported for spam")

        :ok
      end
    end
  end
end
