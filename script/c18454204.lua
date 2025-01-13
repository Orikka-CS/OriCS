--재뉴어리 머큐리
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,nil,1,2,s.pfil1,aux.Stringid(id,2),2)
	local e1=MakeEff(c,"I","M")
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetCL(1)	
	WriteEff(e1,1,"CTO")
	c:RegisterEffect(e1)
end
function s.pfil1(c,tp,xyzc)
	return c:IsFaceup() and c:IsSetCard("재뉴어리",xyzc,SUMMON_TYPE_XYZ,tp)
		and Duel.GetPlayerEffect(tp,EFFECT_JANUARY)
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(10000)
	return true
end
function s.tfil1(c)
	return c:IsSetCard("재뉴어리") and c:IsAbleToDeck()
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then
		if e:GetLabel()==1 then
			return chkc:IsControler(tp) and chkc:IsLoc("G") and chkc:IsAbleToDeck()
		elseif e:GetLabel()==2 then
			return chkc:IsControler(tp) and chkc:IsLoc("G") and s.tfil1(chkc)
		end
		return false
	end
	local b1=(e:GetLabel()==0 or Duel.GetPlayerEffect(tp,EFFECT_JANUARY) or Duel.IEMCard(Card.IsDiscardable,tp,"H",0,101,nil))
		and Duel.IETarget(Card.IsAbleToDeck,tp,"G",0,3,nil)
	local b2=c:CheckRemoveOverlayCard(tp,1,REASON_COST) and Duel.IETarget(s.tfil1,tp,"G",0,3,nil)
	if chk==0 then
		e:SetLabel(0)
		return b1 or b2
	end
	local discard=e:GetLabel()==10000
	local op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,0)},{b2,aux.Stringid(id,1)})
	e:SetLabel(op)
	if op==1 then
		if discard then
			if Duel.GetPlayerEffect(tp,EFFECT_JANUARY) then
				local eset={Duel.GetPlayerEffect(tp,EFFECT_JANUARY)}
				local je=eset[1]
				Duel.Hint(HINT_CARD,0,je:GetHandler():GetCode())
				je:Reset()
			else
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
				local g=Duel.SMCard(tp,Card.IsDiscardable,tp,"H",0,101,101,nil)
				Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
			end
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.STarget(tp,Card.IsAbleToDeck,tp,"G",0,3,3,nil)
		Duel.SOI(0,CATEGORY_TODECK,g,3,0,0)
		Duel.SOI(0,CATEGORY_DRAW,nil,0,tp,1)
	elseif op==2 then
		c:RemoveOverlayCard(tp,1,1,REASON_COST)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.STarget(tp,s.tfil1,tp,"G",0,3,3,nil)
		Duel.SOI(0,CATEGORY_TODECK,g,3,0,0)
		Duel.SOI(0,CATEGORY_DRAW,nil,0,tp,1)
	end
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=e:GetLabel()
	if op==1 then
		local tg=Duel.GetTargetCards(e)
		if #tg>0 and Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
			local og=Duel.GetOperatedGroup()
			if og:IsExists(Card.IsLoc,1,nil,"D") then
				Duel.ShuffleDeck(tp)
			end
			Duel.BreakEffect()
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	elseif op==2 then
		local tg=Duel.GetTargetCards(e)
		if #tg>0 and Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
			local og=Duel.GetOperatedGroup()
			if og:IsExists(Card.IsLoc,1,nil,"D") then
				Duel.ShuffleDeck(tp)
			end
			Duel.BreakEffect()
			Duel.Draw(tp,1,REASON_EFFECT)
		end
		local e1=MakeEff(c,"F")
		e1:SetCode(EFFECT_JANUARY)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTR(1,0)
		Duel.RegisterEffect(e1,tp)
	end
end