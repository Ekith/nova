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
