function dest = mapClosestDelta(fmap, toTest, basis1, basis2)
V1 = basis1;
V2 = basis2;

V1 = V1(toTest,:);
V2 = V2(:,:);

Vc = fmap*V1';

dest = annquery(V2',Vc, 1);
