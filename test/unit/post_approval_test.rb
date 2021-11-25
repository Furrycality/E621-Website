require 'test_helper'

class PostApprovalTest < ActiveSupport::TestCase
  context "a pending post" do
    setup do
      @user = FactoryBot.create(:user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"

      @post = FactoryBot.create(:post, uploader_id: @user.id, tag_string: "touhou", is_pending: true)

      @approver = FactoryBot.create(:user)
      @approver.can_approve_posts = true
      @approver.save
      CurrentUser.user = @approver

      CurrentUser.stubs(:can_approve_posts?).returns(true)
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    should "allow approval" do
      assert_equal(false, @post.approved_by?(@approver))
    end

    context "#search method" do
      should "work" do
        @approval = @post.approve!(@approver)
        @approvals = PostApproval.search(user_name: @approver.name, post_tags_match: "touhou", post_id: @post.id)

        assert_equal([@approval.id], @approvals.map(&:id))
      end
    end
  end
end
