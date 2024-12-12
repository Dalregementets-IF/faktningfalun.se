const THEME_KEY = 'theme';
const cachedTheme = localStorage.getItem(THEME_KEY);

function setPaintborder(theme) {
  if (theme === 'auto') {
    if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
      theme = 'dark';
    } else {
      theme = 'light';
    }
  }
  const overlays = document.getElementsByClassName('paintoverlay');
  for (i in overlays) {
    let item = overlays[i];
    if (item.nodeName !== 'DIV') {
      continue;
    }
    let div = item.querySelector('div');
    if (div) {
      div.classList.remove('light');
      div.classList.remove('dark');
      div.classList.add(theme);
    }
  }
}

const select = document.getElementById('theme-select');
if (select) {
  const defaultOption = select.querySelector('option[selected]');
  if (cachedTheme && cachedTheme !== defaultOption.value) {
    defaultOption.removeAttribute('selected');
    select.querySelector(`option[value="${cachedTheme}"]`).setAttribute('selected', '');
  }

  document.addEventListener("DOMContentLoaded", function () {
    setPaintborder(select.querySelector('option[selected]').value);
  });

  select.addEventListener('change', (e) => {
    const theme = e.target.value;
    setPaintborder(theme);
    if (theme === defaultOption.value) {
      localStorage.removeItem(THEME_KEY);
    } else {
      localStorage.setItem(THEME_KEY, theme);
    }
  });
}
