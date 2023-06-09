% postprocess results from compute_male2fem_fem2male_sensitivity
clearvars

% Get Data
% filename where results are stored 
% Note: file should be made from compute_male2fem_fem2male_sensitivity.m
fname = './results_male2fem_fem2male/12-May-2023_male2femalesens_notes-withflux.mat';
dat = load(fname);

[m2f_xlabs, m2f_data] = getdata(dat, 'm2f');
[f2m_xlabs, f2m_data] = getdata(dat, 'f2m');

% sanity check: check that xlabels are the same
flag = 0;
if size(m2f_xlabs) ~= size(f2m_xlabs)
    flag = 1;
end
for ii = 1:size(m2f_xlabs, 2)
    if ~strcmp(m2f_xlabs, f2m_xlabs)
        flag = 1;
    end
end 
if flag
    error('xlabels do not match')
end
xlabels = m2f_xlabs;

Nan_m2f = find_all_Nan(m2f_data);
Nan_f2m = find_all_Nan(f2m_data);
allNan = intersect(Nan_m2f, Nan_f2m);

[rm_xlabs, rm_m2fdat] = removeAllNan(allNan, xlabels, m2f_data);
[~, rm_f2mdat]        = removeAllNan(allNan, xlabels, f2m_data);



%% make figures
temp = [rm_m2fdat, rm_f2mdat];
clim = [min(temp,[],'all'),max(temp,[],'all')];
cmissing = 'w';
labmissing = '<0.5%';
fsize = 18;
ylabels = {'[PTH]_p', '[Ca^{2+}]_p', '[1,25(OH)_2D_3]_p', '\Gamma_{abs}', '\Gamma_{Bone2Plasma}', '\Gamma_{u}', '\Gamma_{p-f}'};
cmap = winter;

figure(1)
clf

h = heatmap(rm_xlabs, ylabels, rm_m2fdat,...
        'colormap', cmap,...
        'MissingDataColor', cmissing, 'MissingDataLabel', labmissing,...
        'ColorLimits', clim, 'colorbarvisible', 'on');
ylabel('Male')
%Ax = gca;
%Ax.XDisplayLabels = nan(size(Ax.XDisplayData));
h.FontSize = fsize;
%title('Impact of individual sex differences', 'fontsize', 24)


figure(2)
clf
h = heatmap(rm_xlabs, ylabels, rm_f2mdat,...
        'colormap', cmap,...
        'MissingDataColor', cmissing, 'MissingDataLabel', labmissing,...
        'ColorLimits', clim, 'colorbarvisible', 'on');
ylabel('Female')
xlabel('Parameters')
h.FontSize = fsize;

%title('Impact of individual sex differences', 'fontsize', 24)

%------------------
% functions used
%------------------
function [xlabels, round_data] = getdata(dat, m2fORf2m)
    if strcmp(m2fORf2m, 'm2f')
        frac_sens = dat.male2female_frac;
    elseif strcmp(m2fORf2m, 'f2m')
        frac_sens = dat.female2male_frac;
    end
    labels = cell(size(dat.diffIDs));
    for ii = 1:length(dat.diffIDs)
        IDval = dat.diffIDs(ii);
        labels{ii} = convert_param_name(dat.param_names{IDval});
    end
    xlabels = labels;
    round_data = round(frac_sens', 2, 'significant');

    [r,c] = find(abs(round_data) <= 0.5);% r - row values, c - column value
    for ii = 1:length(r)
        round_data(r(ii),c(ii)) = NaN;
    end
end

function AllNan_vals = find_all_Nan(round_data)
    % finds which indices are all Nan values
    PTH_Nan = find(isnan(round_data(1,:)));
    Ca_Nan  = find(isnan(round_data(2,:)));
    temp = intersect(PTH_Nan, Ca_Nan);
    D3_Nan  = find(isnan(round_data(3,:)));
    AllNan_vals = intersect(temp, D3_Nan);
end

function [rmNan_xlabels, rmNan_round_data] = removeAllNan(AllNan_vals, xlabels, round_data)
    % removes columns listed in indices from AllNan_vals
    rmNan_round_data = round_data;
    rmNan_xlabels = xlabels;
    
    rmNan_round_data(:,AllNan_vals) = [];
    for ii = length(AllNan_vals):-1:1
        rmNan_xlabels(AllNan_vals(ii)) = [];
    end
end
