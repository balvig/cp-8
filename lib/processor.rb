require "card_updater"
require "issue_closer"
require "labeler"

class Processor
  def initialize(payload)
    @payload = payload
  end

  def process
    return if event_triggered_by_cp8?

    update_trello_cards
    add_labels
    close_stale_issues
  end

  private

    attr_reader :payload

    def update_trello_cards
      CardUpdater.new(payload).run
    end

    def add_labels
      Labeler.new(repo, payload.issue).run
    end

    def close_stale_issues
      IssueCloser.new(repo).run
    end

    def event_triggered_by_cp8?
      current_user.id == payload.sender&.id
    end

    def current_user
      github.user
    end

    def repo
      payload.repo
    end

    def github
      Cp8.github_client
    end
end
