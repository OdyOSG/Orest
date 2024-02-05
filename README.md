---
title: "Orest Usage"
author: "Alexander Alexeyuk"
output: html_document
---
[Presentation](https://docs.google.com/presentation/d/1_OR9Qn7kT-ukn0h7LkKq1qGs1Y6xGThps_hD1Qpcel8/edit?usp=sharing)



### Load source codes (for units mapping)
#### install and import all required modules

```
import sys
!pip install datasets
!pip install spacy
!pip install https://s3-us-west-2.amazonaws.com/ai2-s2-scispacy/releases/v0.5.1/en_core_sci_sm-0.5.1.tar.gz
import os
path_to_orest_units_package = 'your_path'
os.chdir(path_to_orest_units_package)
import utlts
from utlts import *
```

### Run units mapping
#### Get csv. Notice you need to make sure source_code will be parsed
```
%%time
data = pd.read_csv('/content/test_units.csv')
data['ln'] = data['source_code'].apply(lambda x: len(list(x.encode('ascii',errors='ignore'))))
data = data[data['ln'] < 60]
data['source_code'] = data['source_code'].apply(lambda x: clean_input(x))
dat = DatasetDict({
       'test':Dataset.from_dict({'text':data.source_code})
     })
preds = []
max_len = 60
for datum in tqdm(dat['test']):
    src = datum["text"]
    src_idx = torch.tensor(text_transform_sou(src)).unsqueeze(0).to(device)
    pred_tgt = translate_seq(transformer_model, src_idx, device, max_len)
    pred_tgt = pred_tgt[1:-1]
    pred_sent = ' '.join([tar_vocab.get_itos()[i] for i in pred_tgt])
    preds.append(pred_sent)
```




### Load source codes (for units mapping)
#### install and import all required modules
```
import sys
!pip install datasets
!pip install spacy
!pip install https://s3-us-west-2.amazonaws.com/ai2-s2-scispacy/releases/v0.5.1/en_core_sci_sm-0.5.1.tar.gz
import os
path_to_orest_conditions_package  = 'your_path'
os.chdir(path_to_orest_conditions_package)
import utlts
from utlts import *
```

### Run conditions mapping
#### Get csv. Notice you need to make sure SOURCE_CODE will be parsed correctly
```
%%time
data = pd.read_csv('/content/test.csv')
data['SOURCE_CODE'] = data['SOURCE_CODE'].apply(lambda x: clean_input(str(x)))
dat = DatasetDict({'test':Dataset.from_dict({'text':data.SOURCE_CODE})})
     })
%%time
preds = []
for datum in tqdm(dat['test']['text']):
    src_indexes = torch.tensor(text_transform_sou(datum)).unsqueeze(0).to(device)
    mapped_sentence_ids = translate_seq_beam_search(transformer_model, src_indexes, k=1, device=device, max_len=50)
    mapped_sentence_ids = sorted(mapped_sentence_ids, key= lambda x: x[1], reverse=True)
    translation = [[tar_vocab.get_itos()[i] for i in mapped_sentence[0]] for mapped_sentence in mapped_sentence_ids]
    preds.append(' '.join([i for i in translation[0] if i not in ['<sos>', '<eos>', '<pad>', '<unk>']]))
```
[**GDrive Orest package link**]('https://drive.google.com/drive/folders/1m9MqutlelFXH9ac-Hx_SrPj0jAaSwrAI?usp=sharing)
