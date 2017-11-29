function generate_report(group_name)

figure; hold on
eval([group_name '_report_sym']);
eval([group_name '_report']);
eval(['blended_' group_name '_sym']);
eval(['blended_' group_name]);
xlabel('Geodesic error');
ylabel('Percent of correspondences')
title(group_name);
legend('fmaps sym', 'fmaps ground truth', 'blended sym', 'blended ground truth' )