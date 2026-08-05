async function copyToClipboard(text) {
  try {
    await navigator.clipboard.writeText(text);
    return true;
  } catch (_) {
    const tempTextarea = document.createElement('textarea');
    tempTextarea.value = text;
    tempTextarea.setAttribute('readonly', '');
    tempTextarea.style.position = 'absolute';
    tempTextarea.style.left = '-9999px';
    document.body.appendChild(tempTextarea);
    tempTextarea.select();
    const success = document.execCommand('copy');
    document.body.removeChild(tempTextarea);
    return success;
  }
}

function wireCopyButtons(root) {
  (root || document).querySelectorAll('.copy-btn[data-copy-target]').forEach(function(copyButton) {
    if (copyButton.dataset.wired) return;
    copyButton.dataset.wired = '1';

    const installCommand = document.getElementById(copyButton.getAttribute('data-copy-target'));
    if (!installCommand) return;

    copyButton.addEventListener('click', async function() {
      const text = installCommand.textContent.trim();
      const copied = await copyToClipboard(text);

      if (!copied) {
        copyButton.setAttribute('aria-label', 'Échec de copie');
        setTimeout(function() {
          copyButton.setAttribute('aria-label', 'Copier la commande d\'installation');
        }, 1200);
        return;
      }

      copyButton.classList.add('is-copied');
      copyButton.setAttribute('aria-label', 'Commande copiée');

      setTimeout(function() {
        copyButton.classList.remove('is-copied');
        copyButton.setAttribute('aria-label', 'Copier la commande d\'installation');
      }, 1200);
    });
  });
}

window.addEventListener('DOMContentLoaded', function() {
  wireCopyButtons(document);
});
