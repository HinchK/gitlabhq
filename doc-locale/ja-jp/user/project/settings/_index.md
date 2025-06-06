---
stage: Tenant Scale
group: Organizations
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: プロジェクトの機能と権限
---

{{< details >}}

- プラン: Free、Premium、Ultimate
- 製品: GitLab.com、GitLab Self-Managed、GitLab Dedicated

{{< /details >}}

## プロジェクトの機能と権限を設定する

プロジェクトの機能と権限を設定するには:

1. 左側のサイドバーで、**検索または移動**を選択して、プロジェクトを見つけます。
1. **設定 > 一般**を選択します。
1. **可視性、プロジェクトの機能、権限**を展開します。
1. ユーザーがプロジェクトへのアクセスをリクエストできるようにするには、**ユーザーがアクセスをリクエストできます**チェックボックスをオンにします。
1. プロジェクトの機能をオンまたはオフにするには、機能の切替えを使用します。
1. **変更の保存**を選択します。

### 機能の依存関係

ある機能をオフにすると、別の機能も使用できなくなります。

- **イシュー**機能をオフにすると、プロジェクトユーザーは以下を使用できなくなります。

  - **イシューボード**
  - **サービスデスク**
  - プロジェクトユーザーは、引き続きマージリクエストから**マイルストーン**にアクセス可能

- **イシュー**と**マージリクエスト**をオフにすると、プロジェクトユーザーは以下を使用できなくなります。

  - **ラベル**
  - **マイルストーン**

- **リポジトリ**をオフにすると、プロジェクトユーザーは以下にアクセスできなくなります。

  - **マージリクエスト**
  - **CI/CD**
  - **Git Large File Storage**
  - **パッケージ**

- メトリクスダッシュボードでは、プロジェクト環境とデプロイへの読み取りアクセスが必要です。メトリクスダッシュボードへのアクセス権を持つユーザーは、環境とデプロイにもアクセスできます。

## プロジェクトの機能を切り替える

プロジェクトの利用可能な機能は、プロジェクトメンバーに表示され、プロジェクトメンバーからアクセスできます。プロジェクトの特定の機能をオフにして、役割に関係なく、プロジェクトメンバーが表示およびアクセスできないようにすることができます。

プロジェクト内の個別の機能の利用可能性を切り替えるには:

1. 左側のサイドバーで、**検索または移動**を選択して、プロジェクトを見つけます。
1. **設定 > 一般**を選択します。
1. **可視性、プロジェクトの機能、権限**を展開します。
1. 機能の利用可能性を変更するには、切替をオンまたはオフにします。
1. **変更の保存**を選択します。

## プロジェクト分析をオフにする

デフォルトでは、プロジェクト分析は左側のサイドバーの**分析**項目に表示されます。この機能をオフにして、左側のサイドバーから**分析**項目を削除するには:

1. 左側のサイドバーで、**検索または移動**を選択して、プロジェクトを見つけます。
1. **設定 > 一般**を選択します。
1. **可視性、プロジェクトの機能、権限**を展開します。
1. **分析**切替をオフにします。
1. **変更の保存**を選択します。

## イシューでのCVE識別子リクエストをオフにする

{{< details >}}

- プラン: Free、Premium、Ultimate
- 製品: GitLab.com

{{< /details >}}

{{< history >}}

- GitLab 13.4で[導入](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/41203)されました。GitLab.comの公開プロジェクトのみ対象。

{{< /history >}}

一部の環境では、ユーザーはイシューで[CVE識別子リクエスト](../../application_security/cve_id_request.md)を送信できます。

プロジェクトのイシューでCVE識別子リクエストオプションをオフにするには:

1. 左側のサイドバーで、**検索または移動**を選択して、プロジェクトを見つけます。
1. **設定 > 一般**を選択します。
1. **可視性、プロジェクトの機能、権限**を展開します。
1. **イシュー**で、**イシューサイドバーのCVE IDリクエスト**切替をオフにします。
1. **変更の保存**を選択します。

## プロジェクトのメール通知をオフにする

前提要件:

- プロジェクトのオーナーロールを持っている必要があります。

1. 左側のサイドバーで、**検索または移動**を選択して、プロジェクトを見つけます。
1. **設定 > 一般**を選択します。
1. **表示レベル、プロジェクトの機能、権限**セクションを展開します。
1. **メール通知を有効にする**チェックボックスをオフにします。

### プロジェクトのメール通知で差分プレビューをオフにする

{{< history >}}

- GitLab 15.6で`diff_preview_in_email`[フラグとともに](../../../administration/feature_flags.md)[導入されました](https://gitlab.com/gitlab-org/gitlab/-/issues/24733)。デフォルトでは無効になっています。
- GitLab 17.1で[一般提供](https://gitlab.com/gitlab-org/gitlab/-/issues/382055)になりました。機能フラグ`diff_preview_in_email`は削除されました。

{{< /history >}}

マージリクエストでコードをレビューし、コード行にコメントすると、GitLabは参加者へのメール通知に差分の行を含めます。一部の組織ポリシーでは、メールを安全性の低いシステムとして扱ったり、メール用のインフラストラクチャを自分で管理していなかったりする場合があります。このため、知的財産（IP）またはソースコードのアクセス制御にリスクが生じる可能性があります。

前提要件:

- プロジェクトのオーナーロールを持っている必要があります。

プロジェクトの差分プレビューをオフにするには:

1. 左側のサイドバーで、**検索または移動**を選択して、プロジェクトを見つけます。
1. **設定 > 一般**を選択します。
1. **表示レベル、プロジェクトの機能、権限**セクションを展開します。
1. **差分プレビューを含める**をオフにします。
1. **変更の保存**を選択します。

## プロジェクトのマージリクエスト設定を指定する

プロジェクトのマージリクエスト設定を指定します。

- [マージリクエストの方法](../merge_requests/methods/_index.md)（マージコミット、早送りマージ）を設定します。
- マージリクエストの[説明テンプレート](../description_templates.md)を追加します。
- 次の設定をオンにします。
  - [マージリクエストの承認](../merge_requests/approvals/_index.md)
  - [ステータスチェック](../merge_requests/status_checks.md)
  - [パイプラインが成功した場合のみマージ](../merge_requests/auto_merge.md)
  - [すべてのスレッドが解決された場合のみマージ](../merge_requests/_index.md#prevent-merge-unless-all-threads-are-resolved)
  - [Jiraから関連付けられたイシューが必要](../../../integration/jira/issues.md#require-associated-jira-issue-for-merge-requests-to-be-merged)
  - [デフォルトで**マージリクエストが承認されたときにソースブランチを削除**オプション](#delete-the-source-branch-on-merge-by-default)
- 次の項目を設定します。
  - [提案された変更コミットメッセージ](../merge_requests/reviews/suggestions.md#configure-the-commit-message-for-applied-suggestions)
  - [マージコミットとスカッシュコミットのメッセージテンプレート](../merge_requests/commit_templates.md)
  - フォークからのマージリクエストに対する[デフォルトのターゲットプロジェクト](../merge_requests/creating_merge_requests.md#set-the-default-target-project)。

### デフォルトでマージ時にソースブランチを削除する

マージリクエストでは、**ソースブランチを削除**チェックボックスが常にオンになるように、デフォルトの動作を変更できます。

このデフォルトを設定するには:

1. 左側のサイドバーで、**検索または移動**を選択して、プロジェクトを見つけます。
1. **設定 > マージリクエスト**を選択します。
1. **デフォルトで「ソースブランチを削除」オプションを有効にする**をオンにします。
1. **変更の保存**を選択します。

## プロジェクトアクセストークンの有効期限に関する追加のWebhookトリガーを追加する

{{< history >}}

- GitLab 17.9で、`extended_expiry_webhook_execution_setting`という名前の[フラグ](../../../administration/feature_flags.md)とともに、60日と30日のトリガーがプロジェクトとグループアクセストークンWebhookに[追加](https://gitlab.com/gitlab-org/gitlab/-/issues/463016)されました。デフォルトでは無効になっています。
- GitLab 17.10の[GitLab.comで有効になりました](https://gitlab.com/gitlab-org/gitlab/-/issues/513684)。
- GitLab 17.10で、[一般提供](https://gitlab.com/gitlab-org/gitlab/-/issues/513684)になりました。機能フラグ`extended_expiry_webhook_execution_setting`は削除されました。

{{< /history >}}

{{< alert type="flag" >}}

この機能の利用可能性は、機能フラグによって制御されます。詳細については履歴を参照してください。

{{< /alert >}}

GitLabは、プロジェクトトークンの有効期限が切れる前に、複数の[有効期限メール](project_access_tokens.md#project-access-token-expiry-emails)を送信し、関連する[Webhook](../integrations/webhook_events.md#project-and-group-access-token-events)をトリガーします。デフォルトでは、GitLabはトークンの有効期限が切れる7日前のみにこれらのWebhookをトリガーします。この機能が有効になっている場合、GitLabはトークンの有効期限が切れる60日前と30日前にもこれらのWebhookをトリガーします。

これらのWebhookの追加のトリガーを有効にするには:

1. 左側のサイドバーで、**検索または移動**を選択して、プロジェクトを見つけます。
1. **設定 > 一般**を選択します。
1. **表示レベル、プロジェクトの機能、権限**セクションを展開します。
1. **Extended Group Access Tokens Expiry Webhook execution（拡張グループアクセストークン有効期限Webhookを実行）**チェックボックスをオンにします。
1. **変更の保存**を選択します。
