require 'paths'
require 'optim'
require 'nn'

------------[[Specify your options here]]--------------

local cmd = torch.CmdLine()
cmd:text()
cmd:text('Torch-7 PlantVillage Challenge Training script')
cmd:text()
cmd:option('-learningRate',             0.01,       'initial learning rate for sgd')
cmd:option('-momentum',                 0.9,        'momentum term of sgd')
cmd:option('-maxEpochs',                120,        'Max # Epochs')
cmd:option('-batchSize',                32,         'batch size')
cmd:option('-nbClasses',                38,         '# of classes' )
cmd:option('-nbChannels',               3,          '# of channels' )
cmd:option('-backend',                  'cudnn',    'Options: cudnn | nn')
cmd:option('-model',                    'alexnet',  'Options: alexnet | vgg | resnet')
cmd:option('-depth',                    'A',        'For vgg depth: A | B | C | D, For resnet depth: 18 | 34 | 50 | 101 | ... Not applicable for alexnet')
cmd:option('-retrain',                  'none',     'Path to model to finetune')
cmd:option('-save',                     '.',        'Path to save models')
cmd:option('-data',                     'datasets/crowdai/' ,'Path to folder with train and val directories')

local opt = cmd:parse(arg or {}) -- Table containing all these options


-----------[[Model and criterion here]]---------------
local net; local gpus; local dataParallelContainer;
if opt.retrain ~= 'none' then
    assert(paths.filep(opt.retrain), 'File not found: ' .. opt.retrain)
    print('Loading model from file: ' .. opt.retrain);
    net = torch.load(opt.retrain)

    -- remove final linear layer    
    local orig = net:get(#net.modules)
    assert(torch.type(orig) == 'nn.Linear',
         'expected last layer to be fully connected')
    net:remove(#net.modules) --remove original layer

    net:add(nn.Linear(orig.weight:size(2), opt.nbClasses))
    net:add(nn.LogSoftMax())
else
    createModel = require('models/'..opt.model)
    print('Creating new '..opt.model..' model')
    net = createModel(opt)
end

local criterion = nn.ClassNLLCriterion()

if opt.backend ~= 'nn' then
    require 'cunn'; require 'cudnn'; require 'cutorch'
    cudnn.fastest = true; cudnn.benchmark = true    
    gpus = torch.range(1,cutorch.getDeviceCount()):totable()
    dataParallelContainer = nn.DataParallelTable(1):add(model,gpus):cuda()
    cudnn.convert(dataParallelContainer, cudnn) --Convert the net to cudnn
    if net~= dataParallelContainer then dataParallelContainer:copy(net) end
        collectgarbage()
    criterion = criterion:cuda()
end

require 'datasets/plantvillage.lua'
dgen = DataGen(opt.data)



----[[Get your trainer object and start training]]-----
require 'train.lua'
local trainer = Trainer(net, criterion, dgen, opt)

local bestValLoss = math.huge

for n_epoch = 1,opt.maxEpochs do
    local trainLoss = trainer:train()  --Train on training set
    local valLoss = trainer:validate() --Valiate on valiadation set
    
    -- Checkpoint model every 10 epochs
    if n_epoch%10 == 0 then
        local save_path = paths.concat( opt.save, opt.model..'_'..n_epoch..'.t7')
        torch.save(save_path, net:clearState())
        print("Checkpointing Model")
    end

    -- Early stopping 
    if valLoss <  bestValLoss then
        bestValLoss = valLoss
        print(('Current Best Validation Loss %.5f. Saving the model.'):format(bestValLoss))
        local save_path = paths.concat( opt.save, opt.model..'_best.t7')
        torch.save(save_path, net:clearState())
    end

    print("Epoch "..n_epoch.." complete")
end
