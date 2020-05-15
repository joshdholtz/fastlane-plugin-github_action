describe Fastlane::Actions::GithubActionsAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The github_actions plugin is working!")

      Fastlane::Actions::GithubActionsAction.run(nil)
    end
  end
end
