{s}: 
{
  ghcidScript = s "dev" "ghcid --command 'cabal new-repl lib:qcm-fail' --allow-eval --warnings";
  testScript = s "test" "cabal run test:qcm-fail-tests";
  hoogleScript = s "hgl" "hoogle serve";
}
