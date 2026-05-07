window.UI = {
  alert(el, type, msg) {
    if (!el) return;
    el.className = `alert alert-${type} show`;
    el.textContent = msg;
  },
  clearAlert(el) {
    if (!el) return;
    el.className = 'alert';
    el.textContent = '';
  },
  loading(btn, isLoading) {
    if (!btn) return;
    if (isLoading) {
      btn.classList.add('loading');
      btn.disabled = true;
    } else {
      btn.classList.remove('loading');
      btn.disabled = false;
    }
  },
  bindOtpInputs(container, onComplete) {
    const inputs = Array.from(container.querySelectorAll('input'));
    inputs.forEach((inp, i) => {
      inp.addEventListener('input', () => {
        inp.value = inp.value.replace(/\D/g, '').slice(0, 1);
        if (inp.value && i < inputs.length - 1) inputs[i + 1].focus();
        const code = inputs.map((x) => x.value).join('');
        if (code.length === inputs.length && onComplete) onComplete(code);
      });
      inp.addEventListener('keydown', (e) => {
        if (e.key === 'Backspace' && !inp.value && i > 0) inputs[i - 1].focus();
      });
      inp.addEventListener('paste', (e) => {
        const text = (e.clipboardData || window.clipboardData).getData('text').replace(/\D/g, '');
        if (text) {
          e.preventDefault();
          inputs.forEach((x, idx) => { x.value = text[idx] || ''; });
          inputs[Math.min(text.length, inputs.length) - 1].focus();
          if (text.length >= inputs.length && onComplete) onComplete(text.slice(0, inputs.length));
        }
      });
    });
  },
  getOtpValue(container) {
    return Array.from(container.querySelectorAll('input')).map((x) => x.value).join('');
  },
  startCountdown(el, seconds, onTick, onDone) {
    let s = seconds;
    const tick = () => {
      if (s <= 0) {
        el.textContent = '';
        onDone && onDone();
        return clearInterval(t);
      }
      el.textContent = `Resend code in ${s}s`;
      onTick && onTick(s);
      s--;
    };
    tick();
    const t = setInterval(tick, 1000);
    return () => clearInterval(t);
  },
  qs: (name) => new URLSearchParams(window.location.search).get(name),
};
