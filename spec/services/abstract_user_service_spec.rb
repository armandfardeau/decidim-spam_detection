# frozen_string_literal: true

require "spec_helper"

module Decidim
  module SpamDetection
    describe AbstractUserService do
      let(:subject) { described_class.new(user, 0.0) }
      let(:organization) { create(:organization) }
      let!(:user) { create(:user, organization: organization) }

      describe "#run" do
        it "raises an error" do
          expect { subject.run }.to raise_error(NotImplementedError)
        end
      end

      describe "#moderation_user" do
        it "creates the admin" do
          expect { subject.moderation_user }.to change(Decidim::User, :count)
        end

        context "when moderation admin exists" do
          let!(:moderation_admin) do
            create(:user,
                   :admin,
                   organization: organization,
                   name: "spam detection bot",
                   nickname: "Spam_detection_bot",
                   email: "spam_detection_bot@opensourcepolitcs.eu")
          end

          it "reuses the admin" do
            expect { subject.moderation_user }.not_to change(Decidim::User, :count)
          end
        end

        describe "#spam detection metadata" do
          it "#add spam detection metadata" do
            subject.add_spam_detection_metadata!({ "foo" => "bar" })

            expect(user.reload.extended_data["spam_detection"]).to eq({ "foo" => "bar" })
          end

          context "when extended_data already exist" do
            it "doesn't overrides it" do
              user.update!(extended_data: { "other": "data" })
              subject.add_spam_detection_metadata!({ "foo" => "bar" })

              expect(user.reload.extended_data).to eq({ "other" => "data", "spam_detection" => { "foo" => "bar" } })
            end
          end

          context "when key already exists" do
            it "overrides it" do
              user.update!(extended_data: { "spam_detection" => { "foo" => "bar" } })
              subject.add_spam_detection_metadata!({ "foo" => "barz" })
              expect(user.reload.extended_data["spam_detection"]).to eq({ "foo" => "barz" })
            end
          end
        end
      end
    end
  end
end
