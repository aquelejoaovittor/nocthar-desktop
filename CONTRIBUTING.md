# 🤝 Como Contribuir com o NOCTHAR DESKTOP

Primeiramente, obrigado por considerar contribuir com o NOCTHAR! É graças a pessoas como você que a comunidade Open Source cresce.

## 🐛 Encontrou um Bug?
1. Verifique se o bug já não foi reportado na aba **Issues**.
2. Se não, abra uma nova Issue com o título claro e uma descrição detalhada (incluindo o log de erro, se possível).
3. Informe sua versão do Linux Mint e do MATE.

## 💡 Tem uma Ideia ou Sugestão?
1. Abra uma Issue com a tag `enhancement`.
2. Descreva como a funcionalidade deveria funcionar e por que ela seria útil.

## 💻 Quer enviar código (Pull Request)?
1. Faça um "Fork" do repositório.
2. Crie uma branch para a sua feature: `git checkout -b feature/minha-nova-feature`
3. Faça o commit das suas mudanças seguindo o padrão: `git commit -m 'feat: adiciona nova funcionalidade X'`
4. Envie para o seu Fork: `git push origin feature/minha-nova-feature`
5. Abra um Pull Request explicando detalhadamente o que foi alterado.

## 🎨 Diretrizes de Código
- **Bash:** Use `shellcheck` e mantenha a compatibilidade com `set -Eeuo pipefail`.
- **Python:** Siga a PEP 8. Mantenha a interface responsiva usando `threading` para chamadas de sistema.
- **Segurança:** NUNCA envie scripts que rodam `sudo` sem a confirmação explícita do usuário.

Obrigado! 🌌
