# 🛠️ Painel de Ferramentas de Suporte Windows

Um script Batch interativo para automatizar tarefas de manutenção preventiva, reparo do sistema, reset de rede e geração de relatórios de hardware no Windows.

## 🚀 Funcionalidades

- **Limpeza de Cache e Temporários:** Remove arquivos desnecessários de `%TEMP%`, `Prefetch`, `SoftwareDistribution` e limpa a lixeira.
- **Reset de Rede:** Executa `flushdns`, limpa conexões IP, reinicia a pilha Winsock/TCP-IP e restaura o Windows Firewall.
- **Reparo de Imagem do Sistema:** Executa verificações com `DISM` (`ScanHealth`, `RestoreHealth`) e `SFC /scannow`.
- **Relatório Completo de Hardware e Rede:** Coleta dados do sistema e exporta um arquivo `.txt` detalhado para a Área de Trabalho.
- **Gerenciamento de Spooler:** Limpa a fila de impressão travada e reinicia o serviço de impressoras.
- **Reinício de Serviços Essenciais:** Reinicia serviços de rede, Windows Update e DNS Client.
- **Elevação Automática:** Solicita permissão de Administrador automaticamente na inicialização.

## 📋 Pré-requisitos

- **Sistema Operacional:** Windows 10 ou Windows 11.
- **Permissão:** O script precisa ser executado com privilégios administrativos (a elevação é automática).

## 📥 Como Usar

1. Faça o download do arquivo `suporte.bat` no repositório.
2. Clique duas vezes sobre o arquivo `suporte.bat`.
3. Na janela do Controle de Conta de Usuário (UAC), clique em **Sim** para permitir a execução como Administrador.
4. Escolha as opções desejadas através do menu numérico.

> **Nota:** Logs de execução e relatórios gerados serão salvos diretamente na Área de Trabalho do usuário atual.

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.