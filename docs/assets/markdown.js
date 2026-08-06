// Rendu Markdown minimal, sans dépendance externe.
// Couvre ce qu'on trouve dans un CHANGELOG.md classique (Keep a Changelog) :
// titres, listes, gras/italique, code inline/bloc, liens, règles horizontales.
function novaRenderMarkdown(md) {
  const escapeHtml = novaEscapeHtml;

  function renderInline(text) {
    let out = escapeHtml(text);
    // Code inline : `code`
    out = out.replace(/`([^`]+)`/g, function(_, code) {
      return '<code>' + code + '</code>';
    });
    // Liens : [texte](url)
    out = out.replace(/\[([^\]]+)\]\(([^)\s]+)\)/g, function(_, label, url) {
      return '<a href="' + url + '" rel="noopener">' + label + '</a>';
    });
    // Gras : **texte** ou __texte__
    out = out.replace(/(\*\*|__)(.+?)\1/g, '<strong>$2</strong>');
    // Italique : *texte* ou _texte_
    out = out.replace(/(\*|_)(.+?)\1/g, '<em>$2</em>');
    return out;
  }

  const lines = md.replace(/\r\n/g, '\n').split('\n');
  const html = [];
  let i = 0;
  let listType = null; // 'ul' | 'ol' | null

  function closeList() {
    if (listType) {
      html.push('</' + listType + '>');
      listType = null;
    }
  }

  while (i < lines.length) {
    const line = lines[i];

    // Bloc de code : ```
    if (/^```/.test(line)) {
      closeList();
      const codeLines = [];
      i++;
      while (i < lines.length && !/^```/.test(lines[i])) {
        codeLines.push(lines[i]);
        i++;
      }
      i++; // skip closing fence
      html.push('<pre><code>' + escapeHtml(codeLines.join('\n')) + '</code></pre>');
      continue;
    }

    // Titres : # .. ######
    const headingMatch = /^(#{1,6})\s+(.*)$/.exec(line);
    if (headingMatch) {
      closeList();
      const level = headingMatch[1].length;
      html.push('<h' + level + '>' + renderInline(headingMatch[2].trim()) + '</h' + level + '>');
      i++;
      continue;
    }

    // Règle horizontale
    if (/^(---|\*\*\*|___)\s*$/.test(line)) {
      closeList();
      html.push('<hr>');
      i++;
      continue;
    }

    // Listes à puces : -, *, +
    const bulletMatch = /^\s*[-*+]\s+(.*)$/.exec(line);
    if (bulletMatch) {
      if (listType !== 'ul') {
        closeList();
        html.push('<ul>');
        listType = 'ul';
      }
      html.push('<li>' + renderInline(bulletMatch[1]) + '</li>');
      i++;
      continue;
    }

    // Listes numérotées : 1. 2. ...
    const orderedMatch = /^\s*\d+\.\s+(.*)$/.exec(line);
    if (orderedMatch) {
      if (listType !== 'ol') {
        closeList();
        html.push('<ol>');
        listType = 'ol';
      }
      html.push('<li>' + renderInline(orderedMatch[1]) + '</li>');
      i++;
      continue;
    }

    // Citation : > texte
    const quoteMatch = /^>\s?(.*)$/.exec(line);
    if (quoteMatch) {
      closeList();
      html.push('<blockquote>' + renderInline(quoteMatch[1]) + '</blockquote>');
      i++;
      continue;
    }

    // Ligne vide : ferme la liste courante
    if (line.trim() === '') {
      closeList();
      i++;
      continue;
    }

    // Paragraphe (regroupe les lignes consécutives)
    closeList();
    const paraLines = [line];
    i++;
    while (i < lines.length && lines[i].trim() !== '' &&
           !/^```/.test(lines[i]) && !/^#{1,6}\s/.test(lines[i]) &&
           !/^\s*[-*+]\s+/.test(lines[i]) && !/^\s*\d+\.\s+/.test(lines[i]) &&
           !/^>\s?/.test(lines[i]) && !/^(---|\*\*\*|___)\s*$/.test(lines[i])) {
      paraLines.push(lines[i]);
      i++;
    }
    html.push('<p>' + paraLines.map(renderInline).join('<br>') + '</p>');
  }

  closeList();
  return html.join('\n');
}
