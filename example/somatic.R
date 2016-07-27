# example sciprt performing simple filtering of variants to somatic calls
library(devtools)
install_github("d-cameron/StructuralVariantAnnotation")
library(StructuralVariantAnnotation)

vcf <- readVcf("somatic.gridss.vcf", "hg19")
# filter out low quality calls
vcf <- vcf[rowRanges(vcf)$FILTER %in% c(".", "PASS"),]
# conert to user friendly data frame
vcfdf <- unpack(info(vcf))
# somatic calls have no support in the normal
somatic_vcf <- vcf[vcfdf$SR.1 + vcfdf$RSR.1 + vcfdf$RP.1 + vcfdf$ASSR.1 + vcfdf$ASRP.1 == 0,]
# somatic loss of heterozygosity has no support in the tumour
loh_vcf <- vcf[vcfdf$SR.2 + vcfdf$RSR.2 + vcfdf$RP.2 + vcfdf$ASSR.2 + vcfdf$ASRP.2 == 0,]

# Output BEDPE for use by circos
gr <- breakpointRanges(somatic_vcf)
bedpe <- data.frame(
    chrom1=seqnames(gr),
    start1=start(gr),
    end1=end(gr),
    chrom1=seqnames(partner(gr)),
    start1=start(partner(gr)),
    end1=end(partner(gr)),
    name=names(gr),
    score=gr$QUAL,
    strand1=strand(gr),
    strand2=strand(partner(gr))
    )
# Just the lower of the two breakends so we don't output everything twice
bedpe <- bedpe[str_detect(bedpe$name, "gridss[0-9]+o"),]
write.table(bedpe, "somatic.gridss.hq.somatic.bedpe", quote=FALSE, sep='\t', row.names=FALSE, col.names=FALSE)