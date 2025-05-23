#requires -Module PSDevOps

$Title = "My GitHub Repos"

if (-not $script:CachedRepoList) {
    $script:CachedRepoList = [Ordered]@{}    
    $connectedToGitHub = Connect-GitHub
    $startAutomatingRepos = api.github.com/users/<username>/repos -username StartAutomating
    $psWebRepos = api.github.com/users/<username>/repos -username PowerShellWeb
    $script:CachedRepoList['StartAutomating'] = $startAutomatingRepos
    $script:CachedRepoList['PowerShellWeb'] = $psWebRepos
}

$myRepos = @($script:CachedRepoList.Values) | . { process { $_ } }
$myRepos | ConvertTo-Json -Depth 10 | Set-Content -Path $PSScriptRoot/Repos.json
$myReposByPopularity = $myRepos | Sort-Object stargazers_count -Descending 
$totalStars = ($myRepos | Measure-Object -Property stargazers_count -Sum).Sum
$markdown = @(
"# Most of My Repos"

"(I write a lot of code)"

"## Some Stats:"

"  * $totalStars ★"
"  * $($myRepos.Count) public repos"
"  * $($($myRepos | Where-Object Fork | Measure-Object).Count) of my repos are forks"
"  * $($($myRepos | Measure-Object -Property forks_count -Sum).Sum) forks of my repos"
"  * $($($myRepos | Measure-Object -Property watchers_count -Sum).Sum) watchers of my repos"
"  * $($($myRepos | Measure-Object -Property open_issues_count -Sum).Sum) open issues in my repos"

"## By Popularity:"
foreach ($repoInfo in $myReposByPopularity) {
"  * [$($repoInfo.owner.login)/$($repoInfo.Name)]($($repoInfo.html_url))"
}

"## By Recency:"
foreach ($repoInfo in $myRepos | Sort-Object updated_at -Descending) {
"  * [$($repoInfo.owner.login)/$($repoInfo.Name)]($($repoInfo.html_url))"
}
) -join [Environment]::NewLine

(ConvertFrom-Markdown -InputObject $markdown).Html
