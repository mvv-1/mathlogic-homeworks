module Mathlogic.Deduction where

import Mathlogic.Parser
import Mathlogic

extractPreposition :: File12 -> File12
extractPreposition (File12 (Hdr prepositions expression) (Proof proof)) = (File12 (Hdr (newprep) (Implication (wrap (alpha)) (expression))) (Proof (go [] (map decompose proof) []))) where
    wrap :: Expression -> Disjunction
    wrap e = decompose (Ad (Ac (An e)))
    newprep = init prepositions
    alpha = last prepositions
    go :: [Expression] -> [Expression] -> [Expression] -> [Expression]
    go myProof [] _ = reverse myProof
    go myProof (e:list) rest
        | e == alpha                                 = go (defExpr:(printLemm  myProof)) list (e:rest)
        | (isAxiom e) + (checkPrep newprep e 1) /= 0 = go (defExpr:(printAxiom myProof)) list (e:rest)
        | otherwise                                  = go (defExpr:(printMP    myProof)) list (e:rest)
      where
        defExpr = Implication (decompose (Ad (Ac (An alpha)))) (decompose e)
        printLemm  p = lemmProof ++ p where
            lemmProof = [
                            Implication (decompose (Ad (Ac (An alpha)))) (Implication (decompose (Ad (Ac (An (Implication (decompose (Ad (Ac (An alpha)))) (decompose alpha)))))) (decompose alpha)),
                            Implication (decompose (Ad (Ac (An (Implication (decompose (Ad (Ac (An alpha)))) (Implication (decompose (Ad (Ac (An (Implication (decompose (Ad (Ac (An alpha)))) (decompose alpha)))))) (decompose alpha))))))) (Implication (decompose (Ad (Ac (An (alpha))))) (decompose alpha)),
                            Implication (decompose (Ad (Ac (An (Implication (decompose (Ad (Ac (An (alpha))))) (Implication (decompose (Ad (Ac (An (alpha))))) (decompose alpha))))))) (Implication (decompose (Ad (Ac (An (Implication (decompose (Ad (Ac (An alpha)))) (Implication (decompose (Ad (Ac (An (Implication (decompose (Ad (Ac (An alpha)))) (decompose alpha)))))) (decompose alpha))))))) (Implication (decompose (Ad (Ac (An (alpha))))) (decompose alpha))),
                            Implication (decompose (Ad (Ac (An (alpha))))) (Implication (decompose (Ad (Ac (An (alpha))))) (decompose alpha))
                        ]
        printAxiom p = axiomProof ++ p where
            axiomProof = [
                            Implication (decompose (Ad (Ac (An (e))))) (Implication (decompose (Ad (Ac (An (alpha))))) (decompose e)),
                            decompose e
                         ]
        printMP p = mpProof ++ p where
            dj :: Expression
            dj = intmpexp rest where
                intmpexp :: [Expression] -> Expression
                intmpexp [] = error $ show e
                intmpexp ((Implication j me):rest1)
                    | ((decompose e) == (decompose me)) && (intintmpexp rest) = Ae j
                    | otherwise = intmpexp rest1 where
                        intintmpexp []  = False
                        intintmpexp (test:irest)
                            | (decompose test) == decompose (Ae j) = True
                            | otherwise = intintmpexp irest
                intmpexp (e:rest) = intmpexp rest
            mpProof = [
                        Implication (decompose (Ad (Ac (An (Implication (decompose (Ad (Ac (An alpha)))) (Implication (decompose (Ad (Ac (An dj)))) (decompose e))))))) (Implication (decompose (Ad (Ac (An alpha)))) (decompose e)),
                        Implication (decompose (Ad (Ac (An (Implication (decompose (Ad (Ac (An alpha)))) (decompose dj)))))) (Implication (decompose (Ad (Ac (An (Implication (decompose (Ad (Ac (An alpha)))) (Implication (decompose (Ad (Ac (An dj)))) (decompose e))))))) (Implication (decompose (Ad (Ac (An alpha)))) (decompose e)))
                      ]
