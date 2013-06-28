namespace :terms do
  desc "extracts terms from sentiment lexicon and loads into terms table"
  task extract: :environment do
    IO.foreach("data/SentiWordNet_3.0.0_20130122.txt") do |term| 
      unless term.start_with?("#")
        term.gsub!("\"","'") if term.include?("\"")
        term.chomp!("\n")
        columns = term.split("\t")
        columns[4].split.each do |unique_word|
          word_sense = unique_word.split("#")
          puts word_sense[0]
          Term.create(word:word_sense[0], 
                    sense_number:word_sense[1],
                    pos_score:columns[2],
                    neg_score:columns[3],
                    glossary:columns[5])
        end
      end
    end
  end

  desc "adds emoticons to terms"
  task add_emoticons: :environment do
    Term.create(word:":)",sense_number:1,pos_score:1,neg_score:0,glossary:nil)
    Term.create(word:":-)",sense_number:1,pos_score:1,neg_score:0,glossary:nil)
    Term.create(word:"(:",sense_number:1,pos_score:1,neg_score:0,glossary:nil)
    Term.create(word:";)",sense_number:1,pos_score:1,neg_score:0,glossary:nil)
    Term.create(word:"(;",sense_number:1,pos_score:1,neg_score:0,glossary:nil)
    
    Term.create(word:":(",sense_number:1,pos_score:0,neg_score:1,glossary:nil)
    Term.create(word:":-(",sense_number:1,pos_score:0,neg_score:1,glossary:nil)
    Term.create(word:"):",sense_number:1,pos_score:0,neg_score:1,glossary:nil)
  end

  desc "adds slang to terms"
  task add_slang: :environment do
    Term.create(word:"wtf",sense_number:1,pos_score:0,neg_score:1,glossary:nil)
    Term.create(word:"<3",sense_number:1,pos_score:1,neg_score:0,glossary:nil)
  end

end
