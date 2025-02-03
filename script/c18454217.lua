--고스텔라 스틸레
local m=18454217
local cm=_G["c"..m]
function cm.initial_effect(c)
	local e1=MakeEff(c,"STo")
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
function cm.tfil11(c)
	return c:IsFaceup() and c:IsSetCard("고스텔라")
end
function cm.tfil12(c)
	return c:IsSetCard("고스텔라") and c:IsAbleToHand() and c:IsType(TYPE_MONSTER)
end
function cm.tfil13(c)
	return c:IsAbleToHand() and c:IsType(TYPE_SPELL)
end
function cm.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local sel=0
	local ct=#Duel.GMGroup(cm.tfil11,tp,"M",0,c)
	local dg=Duel.GMGroup(cm.tfil13,tp,"O","O",nil)
	if Duel.IEMCard(cm.tfil12,tp,"D",0,1,nil) then
		sel=sel+1
	end
	if ct>0 and #dg>0 then
		sel=sel+2
	end
	if chk==0 then
		return sel>0
	end
	if sel==3 then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(m,0))
		sel=Duel.SelectOption(tp,aux.Stringid(m,1),aux.Stringid(m,2))+1
	elseif sel==1 then
		Duel.SelectOption(tp,aux.Stringid(m,1))
	else
		Duel.SelectOption(tp,aux.Stringid(m,2))
	end
	e:SetLabel(sel)
	if sel==1 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		Duel.SOI(0,CATEGORY_TOHAND,nil,1,tp,"D")
	else
		e:SetCategory(CATEGORY_TOHAND)
		Duel.SOI(0,CATEGORY_TOHAND,g,1,0,0)
	end
end
function cm.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sel=e:GetLabel()
	if sel==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SMCard(tp,cm.tfil12,tp,"D",0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	else
		local ct=#Duel.GMGroup(cm.tfil11,tp,"M",0,c)
		local g=Duel.GMGroup(cm.tfil13,tp,"O","O",nil)
		if ct>0 and #g>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
			local dg=g:Select(tp,1,ct,nil)
			Duel.HintSelection(dg)
			Duel.SendtoHand(dg,nil,REASON_EFFECT)
		end
	end
end