function test_splatTargets()
    w = 10;
    h = 5;
    r=0.5;
    splatTargets(1, 1, r, w, h) % [1 1]
    splatTargets(10, 9.5, r, w, h) % []
    splatTargets(0, 0.5, r, w, h) % []
    splatTargets(1.1, 1.2, r, w, h) % 1 1
    splatTargets(10, 0.6, r, w, h) % 10 1
    splatTargets(9.8, 9, r, w, h) % 10 9
    splatTargets(1.2, 1.4, r, w, h)
    


end
