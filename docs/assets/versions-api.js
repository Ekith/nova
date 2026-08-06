const NOVA_REPO = 'Ekith/nova';

function novaParseVersion(tag) {
  const parts = tag.split('.').map(function(n) { return parseInt(n, 10); });
  return [parts[0] || 0, parts[1] || 0, parts[2] || 0];
}

function novaCompareVersions(a, b) {
  const va = novaParseVersion(a);
  const vb = novaParseVersion(b);
  for (let i = 0; i < 3; i++) {
    if (va[i] !== vb[i]) return vb[i] - va[i];
  }
  return 0;
}

function novaEscapeHtml(str) {
  return str.replace(/[&<>"']/g, function(c) {
    return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c];
  });
}

// Tags sorted from newest to oldest (semver descending).
function novaFetchTags() {
  return fetch('https://api.github.com/repos/' + NOVA_REPO + '/tags?per_page=100', {
    headers: { Accept: 'application/vnd.github+json' }
  }).then(function(res) {
    if (!res.ok) throw new Error('GitHub API error: ' + res.status);
    return res.json();
  }).then(function(tags) {
    tags.sort(function(a, b) { return novaCompareVersions(a.name, b.name); });
    return tags;
  });
}

function novaFetchBranches() {
  return fetch('https://api.github.com/repos/' + NOVA_REPO + '/branches?per_page=100', {
    headers: { Accept: 'application/vnd.github+json' }
  }).then(function(res) {
    if (!res.ok) throw new Error('GitHub API error: ' + res.status);
    return res.json();
  });
}

// Cherche, toutes branches confondues, le commit le plus récent ayant modifié
// CHANGELOG.md, et renvoie { branch, date, sha } pour la trouvaille la plus récente.
function novaFindLatestChangelogCommit() {
  return novaFetchBranches().then(function(branches) {
    const checks = branches.map(function(branch) {
      const url = 'https://api.github.com/repos/' + NOVA_REPO +
        '/commits?path=CHANGELOG.md&sha=' + encodeURIComponent(branch.name) + '&per_page=1';
      return fetch(url, { headers: { Accept: 'application/vnd.github+json' } })
        .then(function(res) {
          if (!res.ok) return null;
          return res.json();
        })
        .then(function(commits) {
          if (!commits || !commits.length) return null;
          return {
            branch: branch.name,
            date: commits[0].commit.committer.date,
            sha: commits[0].sha
          };
        })
        .catch(function() { return null; });
    });

    return Promise.all(checks).then(function(results) {
      const found = results.filter(Boolean);
      if (!found.length) return null;
      found.sort(function(a, b) { return new Date(b.date) - new Date(a.date); });
      return found[0];
    });
  });
}
