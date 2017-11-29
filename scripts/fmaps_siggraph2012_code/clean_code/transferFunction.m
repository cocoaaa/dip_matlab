function out_f = transferFunction(in_f, basis1, basis2, Fmap)

in_coeffs   = basis1 \ in_f;
out_coeffs  = Fmap * in_coeffs;
out_f       = basis2 * out_coeffs;


