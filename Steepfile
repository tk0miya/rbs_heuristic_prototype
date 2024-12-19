# frozen_string_literal: true

D = Steep::Diagnostic

target :lib do
  signature "sig"

  check "lib"
  implicitly_returns_nil!

  configure_code_diagnostics(D::Ruby.lenient)
end
