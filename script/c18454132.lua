--¸£ºí¶û º£ÀÌÁ÷
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"F","H")
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetTR(POS_FACEUP,1)
	e1:SetCondition(s.con1)
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"S","M")
	e2:SetCode(EFFECT_SET_CONTROL)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCondition(s.con2)
	e2:SetValue(s.val2)
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"STf")
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e3:SetCL(1,id)
	WriteEff(e3,3,"TO")
	c:RegisterEffect(e3)
end
function s.nfil1(c)
	return c:IsSetCard("¸£ºí¶û") and c:IsFaceup()
end
function s.con1(e,c)
	if c==nil then
		return true
	end
	local tp=c:GetControler()
	return Duel.GetLocCount(1-tp,"M")>0 and not Duel.IEMCard(s.nfil1,tp,0,"M",1,nil)
end
function s.con2(e)
	return Duel.IsBattlePhase()
end
function s.val2(e,c)
	local handler=e:GetHandler()
	return handler:GetOwner()
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return true
	end
	local op=c:GetOwner()
	Duel.SPOI(0,CATEGORY_TOHAND,nil,1,op,"D")
	Duel.SPOI(0,CATEGORY_SPECIAL_SUMMON,nil,1,op,"D")
end
function s.ofil3(c,e,tp)
	return c:IsSetCard("¸£ºí¶û") and c:IsType(TYPE_MONSTER)
		and (c:IsAbleToHand() or (Duel.GetLocCount(1-tp,"M")>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)))
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=c:GetOwner()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SMCard(op,s.ofil3,op,"D",0,1,1,nil,e,op)
	local tc=g:GetFirst()
	if not tc then
		return
	end
	aux.ToHandOrElse(tc,op,
		function(sc)
			return sc:IsCanBeSpecialSummoned(e,0,op,false,false,POS_FACEUP,1-op) and Duel.GetLocCount(1-op,"M")>0
		end,
		function(sc)
			Duel.SpecialSummon(sc,0,op,1-op,false,false,POS_FACEUP)
		end,
		aux.Stringid(id,0)
	)
end