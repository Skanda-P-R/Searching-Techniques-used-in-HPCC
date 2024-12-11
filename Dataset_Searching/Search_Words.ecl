﻿IMPORT $;

rec1 := RECORD
 UNSIGNED text_id;
 STRING words;
END;

rec2 := RECORD
 UNSIGNED text_id; 
 STRING text;
END;

test := $.File_Legal.File3;

base_df := $.File_Legal.File1;

x := $.File_Legal.File2;
df1 := x(words<>'extracted_entity');
df2 := test(words<>'words');

tb_rec := RECORD
 df1.text_id;
 df1.words;
END;

tb1 := TABLE(df1,tb_rec,text_id,words);

OUTPUT(base_df,NAMED('Original_Dataset'));
OUTPUT(tb1,NAMED('Extracted_words'));
OUTPUT(df2,NAMED('Test_Data'));

match := JOIN(tb1,df2,LEFT.words=RIGHT.words,
                  TRANSFORM(rec1,
                  SELF := RIGHT,
                  SELF := LEFT),
                  INNER);
                  
OUTPUT(match,NAMED('Matched_Words'));

rec3 := RECORD
 match.text_id;
 UNSIGNED2 Coun := COUNT(GROUP);
 UNSIGNED2 Priority := 0;
END;

tb := TABLE(match,rec3,text_id);

OUTPUT(tb,NAMED('Count_text_id'));

rec3 run(tb Le, tb Ri) := TRANSFORM
 SELF.Priority := IF(Le.Coun=Ri.Coun,Le.Priority,Le.Priority+1);
 SELF := Ri;
END;

prio_df := ITERATE(SORT(tb,-Coun),run(LEFT,RIGHT));

prio_df_rec := RECORD
 prio_df.text_id;
 prio_df.Priority;
END;

prio_df_updated := SORT(TABLE(prio_df,prio_df_rec,text_id,Priority),Priority);
 
OUTPUT(prio_df_updated,NAMED('Priority_of_text_id'));

text_rec := RECORD
 UNSIGNED text_id;
 STRING text;
 UNSIGNED Priority;
END;

get_text := JOIN(base_df,prio_df_updated,LEFT.text_id=RIGHT.text_id,
                  TRANSFORM(text_rec,
                  SELF := RIGHT,
                  SELF := LEFT),
                  INNER);

OUTPUT(SORT(get_text,Priority),NAMED('Final_Text'));